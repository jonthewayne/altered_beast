require File.dirname(__FILE__) + '/../spec_helper'

ModelStubbing.define_models :sites_controller, :copy => :stubbed, :insert => false do
  model Site do
    stub :other, :name => 'other', :host => 'other.test.host'
  end
end

describe SitesController, "GET #index" do
  define_models :sites_controller

  act! { get :index }

  before do
    @sites = [sites(:default), sites(:other)]
    Site.stub!(:find).with(:all).and_return(@sites)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  it.assigns :sites
  it.renders :template, :index
  
  
  describe SitesController, "(xml)" do
    define_models :sites_controller
    
    act! { get :index, :format => 'xml' }

    it.assigns :sites
    it.renders :xml, :sites
  end
end

describe SitesController, "GET #show" do
  define_models :sites_controller

  act! { get :show, :id => 1 }

  before do
    @site  = sites(:default)
    Site.stub!(:find).with('1').and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  it.assigns :site
  it.renders :template, :show
  
  describe SitesController, "(xml)" do
    define_models :sites_controller
    
    act! { get :show, :id => 1, :format => 'xml' }

    it.renders :xml, :site
  end
end

describe SitesController, "GET #new" do
  define_models :sites_controller
  act! { get :new }
  before do
    @site  = Site.new
  end

  it "assigns @site" do
    act!
    assigns[:site].should be_new_record
  end
  
  it.renders :template, :new
  
  describe SitesController, "(xml)" do
    define_models :sites_controller
    act! { get :new, :format => 'xml' }

    it.renders :xml, :site
  end
end

describe SitesController, "GET #edit" do
  define_models :sites_controller
  act! { get :edit, :id => 1 }
  
  before do
    @site  = sites(:default)
    Site.stub!(:find).with('1').and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it.assigns :site
  it.renders :template, :edit
end

describe SitesController, "POST #create" do
  before do
    @attributes = {}
    @site = mock_model Site, :new_record? => false, :errors => []
    Site.stub!(:new).with(@attributes).and_return(@site)
  end
  
  describe SitesController, "(successful creation)" do
    define_models :sites_controller
    act! { post :create, :site => @attributes }

    before do
      @site.stub!(:save).and_return(true)
    end
    
    it.assigns :site, :flash => { :notice => :not_nil }
    it.redirects_to { site_path(@site) }
  end
  
  describe SitesController, "(successful creation, xml)" do
    define_models :sites_controller
    act! { post :create, :site => @attributes, :format => 'xml' }

    before do
      @site.stub!(:save).and_return(true)
      @site.stub!(:to_xml).and_return("<site />")
    end
    
    it.assigns :site, :headers => { :Location => lambda { site_url(@site) } }
    it.renders :xml, :site, :status => :created
  end

  describe SitesController, "(unsuccessful creation)" do
    define_models :sites_controller
    act! { post :create, :site => @attributes }

    before do
      @site.stub!(:save).and_return(false)
    end
    
    it.assigns :site
    it.renders :template, :new
  end
  
  describe SitesController, "(unsuccessful creation, xml)" do
    define_models :sites_controller
    act! { post :create, :site => @attributes, :format => 'xml' }

    before do
      @site.stub!(:save).and_return(false)
    end
    
    it.assigns :site
    it.renders :xml, "site.errors", :status => :unprocessable_entity
  end
end

describe SitesController, "PUT #update" do
  before do
    @attributes = {}
    @site = sites(:default)
    Site.stub!(:find).with('1').and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end
  
  describe SitesController, "(successful save)" do
    define_models :sites_controller
    act! { put :update, :id => 1, :site => @attributes }

    before do
      @site.stub!(:save).and_return(true)
    end
    
    it.assigns :site, :flash => { :notice => :not_nil }
    it.redirects_to { site_path(@site) }
  end
  
  describe SitesController, "(successful save, xml)" do
    define_models :sites_controller
    act! { put :update, :id => 1, :site => @attributes, :format => 'xml' }

    before do
      @site.stub!(:save).and_return(true)
    end
    
    it.assigns :site
    it.renders :blank
  end

  describe SitesController, "(unsuccessful save)" do
    define_models :sites_controller
    act! { put :update, :id => 1, :site => @attributes }

    before do
      @site.stub!(:save).and_return(false)
    end
    
    it.assigns :site
    it.renders :template, :edit
  end
  
  describe SitesController, "(unsuccessful save, xml)" do
    define_models :sites_controller
    act! { put :update, :id => 1, :site => @attributes, :format => 'xml' }

    before do
      @site.stub!(:save).and_return(false)
    end
    
    it.assigns :site
    it.renders :xml, "site.errors", :status => :unprocessable_entity
  end
end

describe SitesController, "DELETE #destroy" do
  define_models :sites_controller
  act! { delete :destroy, :id => 1 }
  
  before do
    @site = sites(:default)
    @site.stub!(:destroy)
    Site.stub!(:find).with('1').and_return(@site)
    @controller.stub!(:admin_required).and_return(true)
  end

  it.assigns :site
  it.redirects_to { sites_path }
  
  describe SitesController, "(xml)" do
    define_models :sites_controller
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it.assigns :site
    it.renders :blank
  end
end