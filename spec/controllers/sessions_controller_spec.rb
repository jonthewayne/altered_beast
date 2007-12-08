require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  define_models

  it 'logins and redirects' do
    post :create, :login => users(:default).login, :password => 'test'
    session[:user].should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :login => users(:default).login, :password => 'bad password'
    session[:user].should be_nil
    response.should be_success
  end

  it 'logs out' do
    login_as :default
    get :destroy
    session[:user].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :login => users(:default).login, :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    post :create, :login => users(:default).login, :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as :default
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'logs in with cookie' do
    users(:default).remember_me
    request.cookies["auth_token"] = cookie_for(:default)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    users(:default).remember_me_until 5.minutes.ago.utc
    request.cookies["auth_token"] = cookie_for(:default)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    users(:default).remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
