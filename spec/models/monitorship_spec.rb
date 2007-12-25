require File.dirname(__FILE__) + '/../spec_helper'

ModelStubbing.define_models :monitorships do
  model Monitorship do
    stub :user => all_stubs(:user), :topic => all_stubs(:topic), :active => true
    stub :inactive, :user => all_stubs(:user), :topic => all_stubs(:other_topic), :active => false
  end
end

describe User, "(monitorships)" do
  define_models :monitorships
  
  it "selects topics" do
    users(:default).monitored_topics.should == [topics(:default)]
  end
end

describe Topic, "(Monitorships)" do
  define_models :monitorships
  
  it "selects users" do
    topics(:default).monitoring_users.should == [users(:default)]
    topics(:other).monitoring_users.should == []
  end
end

describe Monitorship do
  define_models :monitorships

  it "adds user/topic relation" do
    topics(:other_forum).monitoring_users.should == []
    lambda do
      topics(:other_forum).monitoring_users << users(:default)
    end.should change { Monitorship.count }.by(1)
    topics(:other_forum).monitoring_users(true).should == [users(:default)]
  end

  it "adds user/topic relation over inactive monitorship" do
    topics(:other).monitoring_users.should == []
    lambda do
      topics(:other).monitoring_users << users(:default)
    end.should raise_error(ActiveRecord::RecordNotSaved)
    topics(:other).monitoring_users(true).should == [users(:default)]
  end

  %w(user_id topic_id).each do |attr|
    it "requires #{attr}" do
      mod = new_monitorship(:default)
      mod.send("#{attr}=", nil)
      mod.should_not be_valid
      mod.errors.on(attr).should_not be_nil
    end
  end
  
  it "doesn't add duplicate relation" do
    lambda do
      topics(:default).monitoring_users << users(:default)
    end.should raise_error(ActiveRecord::RecordInvalid)
  end
  
  %w(topic user).each do |model|
    it "is cleaned up after a #{model} is deleted" do
      send(model.pluralize, :default).destroy
      lambda do
        monitorships(:default).reload
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end