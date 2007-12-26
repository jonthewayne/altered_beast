%w(behaviors example_group_methods example).each { |lib| require "rspec_on_rails_on_crack/#{lib}" }

Spec::Runner.configuration.include RspecOnRailsOnCrack::Behaviors

class ActionController::TestSession
  def include?(key)
    data.include?(key)
  end
end