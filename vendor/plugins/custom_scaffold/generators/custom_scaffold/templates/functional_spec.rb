require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper'

describe <%= controller_class_name %>Controller, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @<%= table_name %> = []
    <%= class_name %>.stub!(:find).with(:all).and_return(@<%= table_name %>)
  end
  
  it.assigns :<%= table_name %>
  it.renders :template, :index
  
  
  describe <%= controller_class_name %>Controller, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it.assigns :<%= table_name %>
    it.renders :xml, :<%= table_name %>
  end
end

describe <%= controller_class_name %>Controller, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @<%= file_name %>  = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end
  
  it.assigns :<%= file_name %>
  it.renders :template, :show
  
  describe <%= controller_class_name %>Controller, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it.renders :xml, :<%= file_name %>
  end
end

describe <%= controller_class_name %>Controller, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @<%= file_name %>  = <%= class_name %>.new
  end

  it "assigns @<%= file_name %>" do
    act!
    assigns[:<%= file_name %>].should be_new_record
  end
  
  it.renders :template, :new
  
  describe <%= controller_class_name %>Controller, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it.renders :xml, :<%= file_name %>
  end
end

describe <%= controller_class_name %>Controller, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @<%= file_name %>  = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end

  it.assigns :<%= file_name %>
  it.renders :template, :edit
end

describe <%= controller_class_name %>Controller, "POST #create" do
  before do
    @attributes = {}
    @<%= file_name %> = mock_model <%= class_name %>, :new_record? => false, :errors => []
    <%= class_name %>.stub!(:new).with(@attributes).and_return(@<%= file_name %>)
  end
  
  describe <%= controller_class_name %>Controller, "(successful creation)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it.assigns :<%= file_name %>, :flash => { :notice => :not_nil }
    it.redirects_to { <%= file_name %>_path(@<%= file_name %>) }
  end
  
  describe <%= controller_class_name %>Controller, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes, :format => 'xml' }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
      @<%= file_name %>.stub!(:to_xml).and_return("<<%= file_name %> />")
    end
    
    it.assigns :<%= file_name %>, :headers => { :Location => lambda { <%= file_name %>_url(@<%= file_name %>) } }
    it.renders :xml, :<%= file_name %>, :status => :created
  end

  describe <%= controller_class_name %>Controller, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it.assigns :<%= file_name %>
    it.renders :template, :new
  end
  
  describe <%= controller_class_name %>Controller, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :<%= file_name %> => @attributes, :format => 'xml' }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it.assigns :<%= file_name %>
    it.renders :xml, "<%= file_name %>.errors", :status => :unprocessable_entity
  end
end

describe <%= controller_class_name %>Controller, "PUT #update" do
  before do
    @attributes = {}
    @<%= file_name %> = <%= table_name %>(:default)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end
  
  describe <%= controller_class_name %>Controller, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it.assigns :<%= file_name %>, :flash => { :notice => :not_nil }
    it.redirects_to { <%= file_name %>_path(@<%= file_name %>) }
  end
  
  describe <%= controller_class_name %>Controller, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes, :format => 'xml' }

    before do
      @<%= file_name %>.stub!(:save).and_return(true)
    end
    
    it.assigns :<%= file_name %>
    it.renders :blank
  end

  describe <%= controller_class_name %>Controller, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it.assigns :<%= file_name %>
    it.renders :template, :edit
  end
  
  describe <%= controller_class_name %>Controller, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :<%= file_name %> => @attributes, :format => 'xml' }

    before do
      @<%= file_name %>.stub!(:save).and_return(false)
    end
    
    it.assigns :<%= file_name %>
    it.renders :xml, "<%= file_name %>.errors", :status => :unprocessable_entity
  end
end

describe <%= controller_class_name %>Controller, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @<%= file_name %> = <%= table_name %>(:default)
    @<%= file_name %>.stub!(:destroy)
    <%= class_name %>.stub!(:find).with('1').and_return(@<%= file_name %>)
  end

  it.assigns :<%= file_name %>
  it.redirects_to { <%= table_name %>_path }
  
  describe <%= controller_class_name %>Controller, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it.assigns :<%= file_name %>
    it.renders :blank
  end
end