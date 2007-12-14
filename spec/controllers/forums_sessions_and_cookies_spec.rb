require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController, "(forum_page session value)" do
  define_models

  it "GET /index resets forum_page value" do
    @request.session[:forum_page]=Hash.new(1)
    get :index
    assert_equal nil, session[:forum_page]
  end
  
  it "GET /show/1 sets forum_page value" do
    get :show, :id => forums(:default).id, :page => 3 
    session[:forum_page][forums(:default).id].should == 3
  end
end

describe ForumsController, "(remember-me functionality)" do
  define_models

  it "logs in with valid login token" do
    @request.cookies['auth_token'] = CGI::Cookie.new('auth_token', users(:default).remember_token)
    get :index
    controller.send(:current_user).should == users(:default)
  end
end