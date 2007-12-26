module Spec::Example::ExampleGroupMethods
  def acting_block
    @acting_block
  end

  def act!(&block)
    @acting_block = block
  end

  def create_example(description, &implementation) #:nodoc:
    Spec::Example::AwesomeExample.new(description, self, &implementation)
  end
end