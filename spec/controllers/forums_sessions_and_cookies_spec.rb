require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController, "(remember-me functionality)" do
  define_models

  before do
    session[:forums_page] = {}
  end

  it "logs in with valid login token" do
    @request.cookies['auth_token'] = CGI::Cookie.new('auth_token', users(:default).remember_token)
    get :index
    controller.send(:current_user).should == users(:default)
  end
end