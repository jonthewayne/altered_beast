require File.dirname(__FILE__) + '/../spec_helper'

module PostsControllerParentObjects
  def self.included(base)
    base.before do
      @post  = posts(:default)
      @posts = []
      @forum = forums(:default)
      @topic = topics(:default)
      Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
      @forum.stub!(:topics).and_return([@topic])
      @forum.topics.stub!(:find_by_permalink).with('1').and_return(@topic)
      @topic.stub!(:posts).and_return([])
      @topic.posts.stub!(:search).with('foo', :page => 5).and_return(@posts)
      @topic.posts.stub!(:find).with('1').and_return(@post)
      User.stub!(:index_from).and_return({users(:default).id => users(:default)})
    end
  end
end

describe PostsController, "GET #index" do
  include PostsControllerParentObjects
  define_models :stubbed

  act! { get :index, :forum_id => 1, :topic_id => 1, :user => nil, :q => 'foo', :page => 5 }
  
  it_assigns :posts, :forum, :topic, :parent => lambda { @topic }
  it_renders :template, :index

  describe PostsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :forum_id => 1, :topic_id => 1, :user => nil, :q => 'foo', :page => 5, :format => 'xml' }

    it_assigns :posts, :forum, :topic, :parent => lambda { @topic }
    it_renders :xml, :posts
  end
end

describe PostsController, "GET #index (for forums)" do
  define_models :stubbed

  act! { get :index, :forum_id => 1, :page => 5, :q => 'foo' }

  before do
    @posts = []
    @forum = forums(:default)
    @forum.stub!(:posts).and_return([])
    @forum.posts.stub!(:search).with('foo', :page => 5).and_return(@posts)
    Forum.stub!(:find_by_permalink).with('1').and_return(@forum)
    User.stub!(:index_from).and_return({users(:default).id => users(:default)})
  end

  it_assigns :posts, :forum, :topic => nil, :user => nil, :parent => lambda { @forum }
  it_renders :template, :index

  describe PostsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :forum_id => 1, :page => 5, :q => 'foo', :format => 'xml' }

    it_assigns :posts, :forum, :topic => nil, :user => nil, :parent => lambda { @forum }
    it_renders :xml, :posts
  end
end

describe PostsController, "GET #index (for users)" do
  define_models :stubbed

  act! { get :index, :user_id => 1, :q => 'foo', :page => 5 }

  before do
    @posts = []
    @user = users(:default)
    @user.stub!(:posts).and_return([])
    @user.posts.stub!(:search).with('foo', :page => 5).and_return(@posts)
    User.stub!(:find_by_permalink).with('1').and_return(@user)
    User.stub!(:index_from).and_return { raise("Nooooo") }
  end

  it_assigns :posts, :user, :forum => nil, :topic => nil, :parent => lambda { @user }
  it_renders :template, :index

  describe PostsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :user_id => 1, :page => 5, :q => 'foo', :format => 'xml' }

    it_assigns :posts, :user, :forum => nil, :topic => nil, :parent => lambda { @user }
    it_renders :xml, :posts
  end
end

describe PostsController, "GET #index (globally)" do
  define_models :stubbed

  act! { get :index, :page => 5, :q => 'foo' }

  before do
    @posts = []
    Post.stub!(:search).with('foo', :page => 5).and_return(@posts)
    User.stub!(:index_from).and_return({users(:default).id => users(:default)})
  end

  it_assigns :posts, :user => nil, :forum => nil, :topic => nil, :parent => nil
  it_renders :template, :index

  describe PostsController, "(xml)" do
    define_models :stubbed
    
    act! { get :index, :page => 5, :q => 'foo', :format => 'xml' }

    it_assigns :posts, :user => nil, :forum => nil, :topic => nil, :parent => nil
    it_renders :xml, :posts
  end
end

describe PostsController, "GET #show" do
  include PostsControllerParentObjects
  define_models :stubbed

  act! { get :show, :forum_id => 1, :topic_id => 1, :id => 1 }
  
  it_assigns :forum, :topic, :parent => lambda { @topic }, :post => nil
  it_redirects_to { forum_topic_path(@forum, @topic) }
  
  describe PostsController, "(xml)" do
    define_models :stubbed
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }

    act! { get :show, :forum_id => 1, :topic_id => 1, :id => 1, :format => 'xml' }

    it_renders :xml, :post
  end
end

describe PostsController, "GET #new" do
  include PostsControllerParentObjects
  define_models :stubbed
  act! { get :new, :forum_id => 1, :topic_id => 1 }
  before do
    @post  = Post.new
  end

  it_assigns :forum, :topic, :parent => lambda { @topic }

  it "assigns @post" do
    act!
    assigns[:post].should be_new_record
  end
  
  it_renders :template, :new
  
  describe PostsController, "(xml)" do
    define_models :stubbed
    act! { get :new, :forum_id => 1, :topic_id => 1, :format => 'xml' }
    it_assigns :forum, :topic, :parent => lambda { @topic }
    it_renders :xml, :post
  end
end

describe PostsController, "GET #edit" do
  include PostsControllerParentObjects
  define_models :stubbed
  act! { get :edit, :forum_id => 1, :topic_id => 1, :id => 1 }

  it_assigns :post, :forum, :topic, :parent => lambda { @topic }
  it_renders :template, :edit
end

describe PostsController, "POST #create" do
  include PostsControllerParentObjects
  before do
    login_as :default
    @attributes = {:body => 'foo'}
    @post = mock_model Post, :new_record? => false, :errors => []
    @user.stub!(:reply).with(@topic, @attributes[:body]).and_return(@post)
  end
  
  describe PostsController, "(successful creation)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic_id => 1, :post => @attributes }

    before do
      @post.stub!(:new_record?).and_return(false)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }, :flash => { :notice => :not_nil }
    it_redirects_to { forum_topic_post_path(@forum, @topic, @post, :anchor => "post_#{@post.id}") }
  end

  describe PostsController, "(unsuccessful creation)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic_id => 1, :post => @attributes }

    before do
      @post.stub!(:new_record?).and_return(true)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }
    it_renders :template, :new
  end
  
  describe PostsController, "(successful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic_id => 1, :post => @attributes, :format => 'xml' }

    before do
      @post.stub!(:new_record?).and_return(false)
      @post.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }, :headers => { :Location => lambda { forum_topic_post_url(@forum, @topic, @post) } }
    it_renders :xml, :post, :status => :created
  end
  
  describe PostsController, "(unsuccessful creation, xml)" do
    define_models :stubbed
    act! { post :create, :forum_id => 1, :topic_id => 1, :post => @attributes, :format => 'xml' }

    before do
      @post.stub!(:new_record?).and_return(true)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }
    it_renders :xml, "post.errors", :status => :unprocessable_entity
  end
end

describe PostsController, "PUT #update" do
  include PostsControllerParentObjects
  before do
    @attributes = {}
    @post = posts(:default)
    Post.stub!(:find).with('1').and_return(@post)
  end
  
  describe PostsController, "(successful save)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :topic_id => 1, :id => 1, :post => @attributes }

    before do
      @post.stub!(:update_attributes).and_return(true)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }, :flash => { :notice => :not_nil }
    it_redirects_to { forum_topic_path(@forum, @topic, :anchor => "post_#{@post.id}") }
  end

  describe PostsController, "(unsuccessful save)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :topic_id => 1, :id => 1, :post => @attributes }

    before do
      @post.stub!(:update_attributes).and_return(false)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }
    it_renders :template, :edit
  end
  
  describe PostsController, "(successful save, xml)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :topic_id => 1, :id => 1, :post => @attributes, :format => 'xml' }

    before do
      @post.stub!(:update_attributes).and_return(true)
    end
    
    it_assigns :post
    it_renders :blank
  end
  
  describe PostsController, "(unsuccessful save, xml)" do
    define_models :stubbed
    act! { put :update, :forum_id => 1, :topic_id => 1, :id => 1, :post => @attributes, :format => 'xml' }

    before do
      @post.stub!(:update_attributes).and_return(false)
    end
    
    it_assigns :post, :forum, :topic, :parent => lambda { @topic }
    it_renders :xml, "post.errors", :status => :unprocessable_entity
  end
end

describe PostsController, "DELETE #destroy" do
  include PostsControllerParentObjects
  define_models :stubbed
  act! { delete :destroy, :forum_id => 1, :topic_id => 1, :id => 1 }
  
  before do
    @post.stub!(:destroy)
  end

  it_assigns :post, :forum, :topic, :parent => lambda { @topic }
  it_redirects_to { forum_topic_path(@forum, @topic) }
  
  describe PostsController, "(xml)" do
    define_models :stubbed
    act! { delete :destroy, :forum_id => 1, :topic_id => 1, :id => 1, :format => 'xml' }

    it_assigns :post
    it_renders :blank
  end
end