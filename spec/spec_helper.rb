# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'rspec_on_rails_on_crack'
require 'model_stubbing'
require File.dirname(__FILE__) + "/model_stubs"
require 'ruby-debug'
Debugger.start

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  def current_site(site)
    @site = sites(site)
  end

  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    controller.stub!(:current_user).and_return(@user = user ? users(user) : nil)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{users(user).login}:test")}" : nil
  end
end