require File.dirname(__FILE__) + '/../spec_helper'

describe ModeratorshipsController, "POST #create" do
  before do
    @attributes = {'user_id' => users(:default).id.to_s, 'forum_id' => forums(:default).id.to_s}
    @errors     = []
    @errors.stub!(:full_messages).and_return(%w(foo bar))
    @moderatorship = mock_model Moderatorship, :new_record? => false, :errors => @errors, :id => 5, :user => users(:default)
    Moderatorship.stub!(:new).with(@attributes).and_return(@moderatorship)
  end
  
  describe ModeratorshipsController, "(successful creation)" do
    define_models
    act! { post :create, :moderatorship => @attributes }

    before do
      @moderatorship.stub!(:save).and_return(true)
    end
    
    it_assigns :moderatorship, :flash => { :notice => :not_nil }
    it_redirects_to { user_path(users(:default)) }
  end

  describe ModeratorshipsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :moderatorship => @attributes }

    before do
      @moderatorship.stub!(:save).and_return(false)
    end
    
    it_assigns :moderatorship, :flash => {:notice => nil, :error => :not_nil}
    it_redirects_to { user_path(users(:default)) }
  end
  
  describe ModeratorshipsController, "(successful creation, xml)" do
    define_models
    act! { post :create, :moderatorship => @attributes, :format => 'xml' }

    before do
      @moderatorship.stub!(:save).and_return(true)
      @moderatorship.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :moderatorship, :headers => { :Location => lambda { moderatorship_url(@moderatorship) } }
    it_renders :xml, :moderatorship, :status => :created
  end
  
  describe ModeratorshipsController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :moderatorship => @attributes, :format => 'xml' }

    before do
      @moderatorship.stub!(:save).and_return(false)
    end
    
    it_assigns :moderatorship
    it_renders :xml, "moderatorship.errors", :status => :unprocessable_entity
  end
end

describe ModeratorshipsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @moderatorship = moderatorships(:default)
    @moderatorship.stub!(:destroy)
    Moderatorship.stub!(:find).with('1').and_return(@moderatorship)
  end

  it_assigns :moderatorship
  it_redirects_to { user_path(@moderatorship.user) }
  
  describe ModeratorshipsController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :moderatorship
    it_renders :blank
  end
end