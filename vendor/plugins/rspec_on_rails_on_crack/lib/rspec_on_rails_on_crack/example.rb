class Spec::Example::AwesomeExample < Spec::Example::Example
  def initialize(defined_description=nil, example_group=nil, &implementation)
    super(defined_description, &implementation)
    @example_group = example_group
  end
  
  # Checks that the action redirected:
  #
  #   it.redirects_to { foo_path(@foo) }
  # 
  # Provide a better hint than Proc#inspect
  #
  #   it.redirects_to("foo_path(@foo)") { foo_path(@foo) }
  #
  def redirects_to(hint = nil, &route)
    @defined_description = "redirects to #{(hint || route).inspect}"
    @implementation = lambda do
      acting.should redirect_to(instance_eval(&route))
    end
  end

  # Check that an instance variable was set to the instance variable of the same name 
  # in the Spec Example:
  #
  #   it.assigns :foo # => assigns[:foo].should == @foo
  #
  # Check multiple instance variables
  # 
  #   it.assigns :foo, :bar
  #
  # Check the instance variable was set to something more specific
  #
  #   it.assigns :foo => 'bar'
  #
  # Check the instance variable is not nil:
  #
  #   it.assigns :foo => :not_nil # assigns[:foo].should_not be_nil
  #
  # Check the instance variable is nil
  #
  #   it.assigns :foo => nil # => assigns[:foo].should be_nil
  #
  # Check the instance variable was not set at all
  #
  #   it.assigns :foo => :undefined # => controller.send(:instance_variables).should_not include("@foo")
  #
  def assigns(*names)
    if names.size == 1
      if names.first.is_a?(Hash)
        names.first.each do |key, value|
          if @defined_description
            desc, imp = assigns_example_values(key, value)
            create_sub_example desc, &imp if @example_group
          else
            @defined_description, @implementation = assigns_example_values(key, value)
          end
        end
      else
        @defined_description, @implementation = assigns_example_values(names.first, names.first)
      end
    else
      assigns(names.pop) # go forth and recurse!
      names.each do |name|
        desc, imp = assigns_example_values(name, name)
        create_sub_example desc, &imp
      end if @example_group
    end
  end
  
  # See protected #render_blank, #render_template, and #render_xml for details.
  #
  #   it.renders :blank
  #   it.renders :template, :new
  #   it.renders :xml, :foo
  #
  def renders(render_method, *args, &block)
    send("render_#{render_method}", *args, &block)
  end
  
  # Check that the flash variable(s) were assigned
  #
  #   it.assigns_flash :notice => 'foo',
  #     :this_is_nil => nil,
  #     :this_is_undefined => :undefined,
  #     :this_is_set => :not_nil
  #
  def assigns_flash(flash)
    flash.each do |key, value|
      if @defined_description
        desc, imp = assigns_flash_values(key, value)
        create_sub_example desc, &imp
      else
        @defined_description, @implementation = assigns_flash_values(key, value)
      end
    end
  end

  # Check that the session variable(s) were assigned
  #
  #   it.assigns_session :notice => 'foo',
  #     :this_is_nil => nil,
  #     :this_is_undefined => :undefined,
  #     :this_is_set => :not_nil
  #
  def assigns_session(session)
    session.each do |key, value|
      if @defined_description
        desc, imp = assigns_session_values(key, value)
        create_sub_example desc, &imp
      else
        @defined_description, @implementation = assigns_session_values(key, value)
      end
    end
  end

  # Check that the HTTP header(s) were assigned
  #
  #   it.assigns_headers :Location => 'foo',
  #     :this_is_nil => nil,
  #     :this_is_undefined => :undefined,
  #     :this_is_set => :not_nil
  #
  def assigns_headers(headers)
    headers.each do |key, value|
      if @defined_description
        desc, imp = assigns_headers_values(key, value)
        create_sub_example desc, &imp
      else
        @defined_description, @implementation = assigns_headers_values(key, value)
      end
    end
  end
  
protected
  # Creates 2 examples:  One to check that the body is blank,
  # and the other to check the status.  It looks for one option:
  # :status.  If unset, it checks that that the response was a success.
  # Otherwise it takes an integer or a symbol and matches the status code.
  #
  #   it.renders :blank
  #   it.renders :blank, :status => :not_found
  #
  def render_blank(options = {})
    @defined_description = "renders a blank response"
    @implementation = lambda do
      acting do |response|
        response.body.strip.should be_blank
      end
    end
    assert_status options[:status] if @example_group
  end

  # Creates 3 examples: One to check that the given template was rendered.
  # It looks for two options: :status and :format.
  #
  #   it.renders :template, :index
  #   it.renders :template, :index, :status => :not_found
  #   it.renders :template, :index, :format => :xml
  #
  # If :status is unset, it checks that that the response was a success.
  # Otherwise it takes an integer or a symbol and matches the status code.
  #
  # If :format is unset, it checks that the action is Mime:HTML.  Otherwise
  # it attempts to match the mime type using Mime::Type.lookup_by_extension.
  #
  def render_template(template_name, options = {})
    @defined_description = "renders #{template_name}"
    @implementation = lambda do
      acting.should render_template(template_name.to_s)
    end
    if @example_group
      assert_status options[:status]
      assert_content_type options[:format]
    end
  end

  # Creates 3 examples: One to check that the given XML was returned.
  # It looks for two options: :status and :format.
  #
  # Checks that the xml matches a given string
  #
  #   it.renders(:xml) { "<foo />" }
  #
  # Checks that the xml matches @foo.to_xml
  #
  #   it.renders :xml, :foo
  #
  # Checks that the xml matches @foo.errors.to_xml
  #
  #   it.renders :xml, "foo.errors"
  #
  #   it.renders :xml, :index, :status => :not_found
  #   it.renders :xml, :index, :format => :xml
  #
  # If :status is unset, it checks that that the response was a success.
  # Otherwise it takes an integer or a symbol and matches the status code.
  #
  # If :format is unset, it checks that the action is Mime:HTML.  Otherwise
  # it attempts to match the mime type using Mime::Type.lookup_by_extension.
  #
  def render_xml(record = nil, options = {}, &block)
    if record.is_a?(Hash)
      options = record
      record  = nil
    end
    @defined_description = "renders xml"
    @implementation = lambda do
      if record
        pieces = record.to_s.split(".")
        record = instance_variable_get("@#{pieces.shift}")
        record = record.send(pieces.shift) until pieces.empty?
      end
      block ||= lambda { record.to_xml }
      acting.should have_text block.call
    end
    if @example_group
      assert_status options[:status]
      assert_content_type options[:format] || :xml
    end
  end

  def assigns_example_values(name, value)
    ["assigns @#{name}", lambda do
      act!
      value = 
        case value
        when :not_nil
          assigns[name].should_not be_nnil
        when :undefined
          controller.send(:instance_variables).should_not include("@#{name}")
        when Symbol
          assigns[name].should == instance_variable_get("@#{value}")
        end
      
    end]
  end
  
  {:headers => :to_s, :flash => nil, :session => nil}.each do |collection_type, collection_op|
    define_method "assigns_#{collection_type}_values" do |key, value|
      key = key.send(collection_op) if collection_op
      ["assigns #{collection_type}[#{key.inspect}]", lambda do
        acting do |resp|
          collection = resp.send(collection_type)
          case value
            when nil
              collection[key].should be_nil
            when :not_nil
              collection[key].should_not be_nil
            when :undefined
              collection.should_not include(key)
            when Proc
              collection[key].should == instance_eval(&value)
            else
              collection[key].should == value
          end
        end
      end]
    end
  end

  def assert_content_type(type = :html)
    mime = Mime::Type.lookup_by_extension((type || :html).to_s)
    create_sub_example "renders with Content-Type of #{mime}" do
      acting.content_type.should == mime
    end
  end
  
  def assert_status(status)
    case status
    when String, Fixnum
      code = ActionController::StatusCodes::STATUS_CODES[status.to_i]
      create_sub_example "renders with status of #{code.inspect}" do
        acting.code.should == status.to_s
      end
    when Symbol
      code_value = ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[status]
      code       = ActionController::StatusCodes::STATUS_CODES[code_value]
      create_sub_example "renders with status of #{code.inspect}" do
        acting.code.should == code_value.to_s
      end
    else
      create_sub_example "is successful" do
        acting.should be_success
      end
    end
  end
  
  def create_sub_example(desc, &imp)
    @example_group.send(:example_objects) << Spec::Example::AwesomeExample.new(desc, @example_group, &imp)
  end
end