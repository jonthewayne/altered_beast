require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController, "GET #index" do
  define_models :stubbed

  act! { get :index }

  before do
    @site   = sites(:default)
    @forums = [forums(:other), forums(:default)]
    @site.stub!(:ordered_forums).and_return(@forums)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
    session[:forums_page] = {1 => 5}
    @forum_time = session[:forums] = {1 => 5.minutes.ago.utc}
  end
  
  it_assigns :forums, :session => {:forums_page => nil, :forums => lambda { @forum_time }}
  it_renders :template, :index
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :format => 'xml' }

    it_assigns :forums
    it_renders :xml, :forums
  end
end

describe ForumsController, "GET #show" do
  define_models :stubbed

  act! { get :show, :id => 1 }

  before do
    @site   = sites(:default)
    @forum  = forums(:default)
    @topics = [topics(:default)]
    @site.forums.stub!(:find_by_permalink).with('1').and_return(@forum)
    @forum.topics.stub!(:paginate).with(:page => 1).and_return(@topics)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
    @controller.stub!(:logged_in?).and_return(false)
    @forum_page = session[:forums_page] = {@forum.id => 1}
    @forum_time = session[:forums]      = {@forum.id => Time.utc(2007, 1, 1)}
  end
  
  it_assigns :topics, :forum, :session => {:forums_page => lambda { @forum_page }, :forums => lambda { @forum_time }}
  it_renders :template, :show
  
  it "sets session[:forums] if logged in" do
    @controller.stub!(:logged_in?).and_return(true)
    act!
    session[:forums][@forum.id].should == current_time
  end
  
  describe ForumsController, "(paged)" do
    define_models :stubbed
    act! { get :show, :id => 1, :page => 5 }
    before do
      @forum.topics.stub!(:paginate).with(:page => 5).and_return(@topics)
    end
    
    it_assigns :session => { :forums_page => lambda { {@forum.id => 5} } }
  end
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_assigns :topics => :undefined
    it_renders :xml, :forum
  end
end

describe ForumsController, "GET #new" do
  define_models :stubbed
  act! { get :new }
  before do
    @site   = sites(:default)
    @forum  = Forum.new
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it "assigns @forum" do
    act!
    assigns[:forum].should be_new_record
  end
  
  it_renders :template, :new
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
    act! { get :new, :format => 'xml' }

    it_renders :xml, :forum
  end
end

describe ForumsController, "GET #edit" do
  define_models :stubbed
  act! { get :edit, :id => 1 }
  
  before do
    @site   = sites(:default)
    @forum  = forums(:default)
    @site.forums.stub!(:find_by_permalink).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it_assigns :forum
  it_renders :template, :edit
end

describe ForumsController, "POST #create" do
  before do
    @attributes = {'name' => "Default"}
    @forum      = mock_model Forum, :new_record? => false, :errors => []
    @site       = sites(:default)
    @site.forums.stub!(:build).with(@attributes).and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  describe ForumsController, "(successful creation)" do
    define_models :stubbed
    act! { post :create, :forum => @attributes }

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it_assigns :forum, :flash => { :notice => :not_nil }
    it_redirects_to { forum_path(@forum) }
  end
  
  describe ForumsController, "(successful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum => @attributes, :format => 'xml' }

    before do
      @forum.stub!(:save).and_return(true)
      @forum.stub!(:to_xml).and_return("<forum />")
    end
    
    it_assigns :forum, :headers => { :Location => lambda { forum_url(@forum) } }
    it_renders :xml, :forum, :status => :created
  end

  describe ForumsController, "(unsuccessful creation)" do
    define_models :stubbed
    act! { post :create, :forum => @attributes }

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it_assigns :forum
    it_renders :template, :new
  end
  
  describe ForumsController, "(unsuccessful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum => @attributes, :format => 'xml' }

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it_assigns :forum
    it_renders :xml, "forum.errors", :status => :unprocessable_entity
  end
end

describe ForumsController, "PUT #update" do
  before do
    @attributes = {'name' => "Default"}
    @forum      = forums(:default)
    @site       = sites(:default)
    @site.forums.stub!(:find_by_permalink).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  describe ForumsController, "(successful save)" do
    define_models :stubbed
    act! { put :update, :id => 1, :forum => @attributes }

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it_assigns :forum, :flash => { :notice => :not_nil }
    it_redirects_to { forum_path(@forum) }
  end
  
  describe ForumsController, "(successful save, xml)" do
    define_models :stubbed
    act! { put :update, :id => 1, :forum => @attributes, :format => 'xml' }

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it_assigns :forum
    it_renders :blank
  end

  describe ForumsController, "(unsuccessful save)" do
    define_models :stubbed
    act! { put :update, :id => 1, :forum => @attributes }

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it_assigns :forum
    it_renders :template, :edit
  end
  
  describe ForumsController, "(unsuccessful save, xml)" do
    define_models :stubbed
    act! { put :update, :id => 1, :forum => @attributes, :format => 'xml' }

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it_assigns :forum
    it_renders :xml, "forum.errors", :status => :unprocessable_entity
  end
end

describe ForumsController, "DELETE #destroy" do
  define_models :stubbed
  act! { delete :destroy, :id => 1 }
  
  before do
    @forum      = forums(:default)
    @forum.stub!(:destroy)
    @site       = sites(:default)
    @site.forums.stub!(:find_by_permalink).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it_assigns :forum
  it_redirects_to { forums_path }
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :forum
    it_renders :blank
  end
end