module RspecOnRailsOnCrack
  module Behaviors
    def acting(&block)
      act!
      block.call(response) if block
      response
    end
  
    def act!
      instance_eval &self.class.acting_block
    end
  end
end