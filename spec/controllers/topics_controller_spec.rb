require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController, "GET #index" do
  define_models :stubbed

  act! { get :index, :forum_id => 1 }
  
  it_assigns :topics => :nil, :forum => :nil
  it_redirects_to { forum_path(@forum) }

  describe TopicsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :forum_id => 1, :page => 5, :format => 'xml' }

    before do
      @forum  = forums(:default)
      Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
      @topics = []
      @forum.stub!(:topics).and_return([])
      @forum.topics.stub!(:paginate).with(:page => 5).and_return(@topics)
    end

    it_assigns :topics, :forum
    it_renders :xml, :topics
  end
end

describe TopicsController, "GET #show" do
  define_models :stubbed

  act! { get :show, :forum_id => 1, :id => 1, :page => 5 }

  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @posts = []
    @topic  = topics(:default)
    @topic.stub!(:hit!)
    @forum.stub!(:topics).and_return([])
    @topic.stub!(:posts).and_return([])
    @topic.posts.stub!(:paginate).with(:page => 5).and_return(@posts)
    @forum.topics.stub!(:find_by_permalink).with('1').and_return(@topic)
  end
  
  it_assigns :topic, :forum, :posts, :session => {:topics => nil}
  it_renders :template, :show
  
  it "should render atom feed" do
    pending "no atom support yet"
  end
  
  it "increments topic hit count" do
    @topic.should_receive(:hit!)
    act!
  end
  
  it "assigns new post record" do
    act!
    assigns[:post].should be_new_record
  end
  
  describe TopicsController, "(logged in)" do
    define_models :stubbed

    act! { get :show, :forum_id => 1, :id => 1, :page => 5 }
  
    before do
      controller.stub!(:current_user).and_return(users(:default))
      controller.current_user.stub!(:seen!)
    end

    it_assigns :topic, :forum, :session => {:topics => :not_nil}
  
    it "increments topic hit count" do
      @topic.user_id = 5
      @topic.should_receive(:hit!)
      act!
    end
  
    it "doesn't increment topic hit count for same user" do
      @topic.stub!(:hit!).and_return { raise "Noooooo" }
      act!
    end
    
    it "marks User#last_seen_at" do
      controller.current_user.should_receive(:seen!)
      act!
    end
  end
  
  describe TopicsController, "(xml)" do
    define_models :stubbed
    
    act! { get :show, :forum_id => 1, :id => 1, :format => 'xml' }

    it_assigns :topic, :post => nil, :posts => nil

    it_renders :xml, :topic
  end
end

describe TopicsController, "GET #new" do
  define_models :stubbed
  act! { get :new, :forum_id => 1 }
  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @topic  = Topic.new
  end

  it_assigns :forum

  it "assigns @topic" do
    act!
    assigns[:topic].should be_new_record
  end
  
  it_renders :template, :new
  
  describe TopicsController, "(xml)" do
    define_models :stubbed
    act! { get :new, :forum_id => 1, :format => 'xml' }

    it_renders :xml, :topic
  end
end

describe TopicsController, "GET #edit" do
  define_models :stubbed
  act! { get :edit, :forum_id => 1, :id => 1 }
  
  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @forum.stub!(:topics).and_return([])
    @topic  = topics(:default)
    @forum.topics.stub!(:find_by_permalink).with('1').and_return(@topic)
  end

  it_assigns :topic, :forum
  it_renders :template, :edit
end

describe TopicsController, "POST #create" do
  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @forum.stub!(:topics).and_return([])
    @attributes = {}
    @topic = mock_model Topic, :new_record? => false, :errors => []
    @forum.topics.stub!(:post!).with(@attributes, :false).and_return(@topic)
  end
  
  describe TopicsController, "(successful creation)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic => @attributes }

    before do
      @topic.stub!(:new_record?).and_return(false)
    end
    
    it_assigns :topic, :flash => { :notice => :not_nil }
    it_redirects_to { forum_topic_path(@forum, @topic) }
  end

  describe TopicsController, "(unsuccessful creation)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic => @attributes }

    before do
      @topic.stub!(:new_record?).and_return(true)
    end
    
    it_assigns :topic
    it_renders :template, :new
  end
  
  describe TopicsController, "(successful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic => @attributes, :format => 'xml' }

    before do
      @topic.stub!(:new_record?).and_return(false)
      @topic.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :topic, :headers => { :Location => lambda { forum_topic_url(@forum, @topic) } }
    it_renders :xml, :topic, :status => :created
  end
  
  describe TopicsController, "(unsuccessful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic => @attributes, :format => 'xml' }

    before do
      @topic.stub!(:new_record?).and_return(true)
    end
    
    it_assigns :topic
    it_renders :xml, "topic.errors", :status => :unprocessable_entity
  end
end

describe TopicsController, "PUT #update" do
  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @attributes = {}
    @topic = topics(:default)
    @forum.stub!(:topics).and_return([])
    @forum.topics.stub!(:find_by_permalink).with('1').and_return(@topic)
  end
  
  describe TopicsController, "(successful save)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :id => 1, :topic => @attributes }

    before do
      @topic.stub!(:save).and_return(true)
    end
    
    it_assigns :topic, :flash => { :notice => :not_nil }
    it_redirects_to { forum_topic_path(@forum, @topic) }
  end

  describe TopicsController, "(unsuccessful save)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :id => 1, :topic => @attributes }

    before do
      @topic.stub!(:save).and_return(false)
    end
    
    it_assigns :topic
    it_renders :template, :edit
  end
  
  describe TopicsController, "(successful save, xml)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :id => 1, :topic => @attributes, :format => 'xml' }

    before do
      @topic.stub!(:save).and_return(true)
    end
    
    it_assigns :topic
    it_renders :blank
  end
  
  describe TopicsController, "(unsuccessful save, xml)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :id => 1, :topic => @attributes, :format => 'xml' }

    before do
      @topic.stub!(:save).and_return(false)
    end
    
    it_assigns :topic
    it_renders :xml, "topic.errors", :status => :unprocessable_entity
  end
end

describe TopicsController, "DELETE #destroy" do
  define_models :stubbed
  act! { delete :destroy, :forum_id => 1, :id => 1 }
  
  before do
    @forum  = forums(:default)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    @forum.stub!(:topics).and_return([])
    @topic = topics(:default)
    @topic.stub!(:destroy)
    @forum.topics.stub!(:find_by_permalink).with('1').and_return(@topic)
  end

  it_assigns :topic
  it_redirects_to { forum_path(@forum) }
  
  describe TopicsController, "(xml)" do
    define_models :stubbed
    act! { delete :destroy, :forum_id => 1, :id => 1, :format => 'xml' }

    it_assigns :topic
    it_renders :blank
  end
end