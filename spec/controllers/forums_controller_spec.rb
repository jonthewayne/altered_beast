require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController, "GET #index" do
  define_models :stubbed

  before do
    @site   = sites(:default)
    @forums = [forums(:other), forums(:default)]
    @site.stub!(:ordered_forums).and_return(@forums)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
    session[:forum_page] = 5
  end

  it "sets @forums" do
    act!
    assigns[:forums].should == @forums
  end
  
  it "clears session[:forum_page]" do
    act!
    session[:forum_page].should be_nil
  end
  
  it "renders index.html.erb" do
    act!
    response.should render_template('index')
  end
  
  it "is successful" do
    act!
    response.should be_success
  end
  
  it "renders as html" do
    act!
    response.content_type.should == Mime::HTML
  end
  
  def act!
    get :index
  end  
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
  
    it "returns xml" do
      act!
      response.should have_text(@forums.to_xml)
    end
  
    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end

    it "is successful" do
      act!
      response.should be_success
    end

    def act!
      get :index, :format => 'xml'
    end
  end
end

describe ForumsController, "GET #show" do
  define_models :stubbed

  before do
    @site   = sites(:default)
    @forum  = forums(:default)
    @topics = [topics(:default)]
    @site.forums.stub!(:find).with('1').and_return(@forum)
    @forum.topics.stub!(:paginate).with(:page => nil).and_return(@topics)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
    @controller.stub!(:logged_in?).and_return(false)
  end

  it "does not set session[:forums]" do
    act!
    session[:forums].should be_nil
  end
  
  it "sets session[:forums] if logged in" do
    @controller.stub!(:logged_in?).and_return(true)
    act!
    session[:forums][@forum.id].should == current_time
  end
  
  it "does not set session[:forum_page]" do
    act!
    session[:forum_page].should be_nil
  end
  
  it "sets session[:forums] if page number set" do
    @forum.topics.stub!(:paginate).with(:page => '5').and_return(@topics)
    act! :page => 5
    session[:forum_page][@forum.id].should == 5
  end

  it "sets @topics" do
    act!
    assigns[:topics].should == @topics
  end

  it "sets @forum" do
    act!
    assigns[:forum].should == @forum
  end
  
  it "renders show.html.erb" do
    act!
    response.should render_template('show')
  end
  
  it "is successful" do
    act!
    response.should be_success
  end
  
  it "renders as html" do
    act!
    response.content_type.should == Mime::HTML
  end
  
  def act!(options = {})
    get :show, options.merge(:id => 1)
  end
  
  describe ForumsController, "(xml)" do
    define_models :stubbed

    it "not set @topics" do
      act!
      assigns[:topics].should be_nil
    end

    it "returns xml" do
      act!
      response.should have_text(@forum.to_xml)
    end
  
    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end

    it "is successful" do
      act!
      response.should be_success
    end

    def act!
      get :show, :id => 1, :format => 'xml'
    end
  end
end

describe ForumsController, "GET #new" do
  define_models :stubbed

  before do
    @site   = sites(:default)
    @forum  = Forum.new
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it "sets @forum" do
    act!
    assigns[:forum].should be_new_record
  end
  
  it "renders new.html.erb" do
    act!
    response.should render_template('new')
  end
  
  it "is successful" do
    act!
    response.should be_success
  end
  
  it "renders as html" do
    act!
    response.content_type.should == Mime::HTML
  end
  
  def act!
    get :new
  end  
  
  describe ForumsController, "(xml)" do
    define_models :stubbed

    it "returns xml" do
      act!
      response.should have_text(@forum.to_xml)
    end
  
    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end

    it "is successful" do
      act!
      response.should be_success
    end

    def act!
      get :new, :format => 'xml'
    end
  end
end

describe ForumsController, "GET #edit" do
  define_models :stubbed

  before do
    @site   = sites(:default)
    @forum  = forums(:default)
    @site.forums.stub!(:find).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it "sets @forum" do
    act!
    assigns[:forum].should == @forum
  end
  
  it "renders edit.html.erb" do
    act!
    response.should render_template('edit')
  end
  
  it "is successful" do
    act!
    response.should be_success
  end
  
  it "renders as html" do
    act!
    response.content_type.should == Mime::HTML
  end
  
  def act!
    get :edit, :id => 1
  end
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

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it "sets flash[:notice]" do
      act!
      flash[:notice].should_not be_nil
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "redirects to forum url" do
      act!
      response.should redirect_to(forum_path(@forum))
    end
  end
  
  describe ForumsController, "(successful creation, xml)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
    
    it "returns created status" do
      act!
      response.code.should == "201"
    end
    
    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end
    
    it "sets location header for new record" do
      act!
      response.headers['Location'].should == forum_url(@forum)
    end
    
    it "renders xml" do
      @forum.stub!(:to_xml).and_return("<forum />")
      act!
      response.should have_text(@forum.to_xml)
    end

    def act!
      post :create, :forum => @attributes, :format => 'xml'
    end
  end

  describe ForumsController, "(unsuccessful creation)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "is successful" do
      act!
      response.should be_success
    end
    
    it "renders as html" do
      act!
      response.content_type.should == Mime::HTML
    end
  
    it "renders new.html.erb" do
      act!
      response.should render_template('new')
    end
  end
  
  describe ForumsController, "(unsuccessful creation, xml)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "returns content type of 422" do
      act!
      response.code.should == '422'
    end

    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end
    
    it "renders xml" do
      act!
      response.should have_text(@forum.errors.to_xml)
    end


    def act!
      post :create, :forum => @attributes, :format => 'xml'
    end
  end

  def act!
    post :create, :forum => @attributes
  end
end

describe ForumsController, "PUT #update" do
  before do
    @attributes = {'name' => "Default"}
    @forum      = forums(:default)
    @site       = sites(:default)
    @site.forums.stub!(:find).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  describe ForumsController, "(successful save)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it "sets flash[:notice]" do
      act!
      flash[:notice].should_not be_nil
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "redirects to forum url" do
      act!
      response.should redirect_to(forum_path(@forum))
    end
  end
  
  describe ForumsController, "(successful save, xml)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(true)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
    
    it "is successful" do
      act!
      response.should be_success
    end
    
    it "renders empty response" do
      act!
      response.body.strip.should be_blank
    end

    def act!
      put :update, :id => 1, :forum => @attributes, :format => 'xml'
    end
  end

  describe ForumsController, "(unsuccessful save)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "is successful" do
      act!
      response.should be_success
    end
    
    it "renders as html" do
      act!
      response.content_type.should == Mime::HTML
    end
  
    it "renders edit.html.erb" do
      act!
      response.should render_template('edit')
    end
  end
  
  describe ForumsController, "(unsuccessful save, xml)" do
    define_models :stubbed

    before do
      @forum.stub!(:save).and_return(false)
    end
    
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "returns content type of 422" do
      act!
      response.code.should == '422'
    end

    it "renders as xml" do
      act!
      response.content_type.should == Mime::XML
    end
    
    it "renders xml" do
      act!
      response.should have_text(@forum.errors.to_xml)
    end

    def act!
      put :update, :id => 1, :forum => @attributes, :format => 'xml'
    end
  end

  def act!
    put :update, :id => 1, :forum => @attributes
  end
end

describe ForumsController, "DELETE #destroy" do
  define_models :stubbed
  before do
    @forum      = forums(:default)
    @forum.stub!(:destroy)
    @site       = sites(:default)
    @site.forums.stub!(:find).with('1').and_return(@forum)
    @controller.stub!(:current_site).and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it "sets @forum" do
    act!
    assigns[:forum].should == @forum
  end
  
  it "redirects to index" do
    act!
    response.should redirect_to(forums_path)
  end
  
  def act!
    delete :destroy, :id => 1
  end
  
  describe ForumsController, "(xml)" do
    define_models :stubbed
    it "sets @forum" do
      act!
      assigns[:forum].should == @forum
    end
  
    it "is successful" do
      act!
      response.should be_success
    end
    
    it "renders empty response" do
      act!
      response.body.strip.should be_blank
    end
  
    def act!
      delete :destroy, :id => 1, :format => 'xml'
    end
  end
end