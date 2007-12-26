module RspecOnRailsOnCrack
  module Behaviors
    def acting(&block)
      act!
      block.call(response) if block
      response
    end

    def assert_collection_value(collection, key, expected)
      case expected
        when nil
          collection[key].should be_nil
        when :not_nil
          collection[key].should_not be_nil
        when :undefined
          collection.should_not include(key)
        else
          collection[key].should == expected
      end
    end
  
    def act!
      instance_eval &self.class.acting_block
    end
  end
end