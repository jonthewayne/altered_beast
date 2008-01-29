require File.dirname(__FILE__) + '/../spec_helper'

module TopicCreatePostHelper
  def self.included(base)
    base.define_models
    
    base.before do
      @user  = users(:default)
      @attributes = {:body => 'booya'}
      @creating_topic = lambda { post! }
    end
  
    base.it "sets topic's last_updated_at" do
      @topic = post!
      @topic.should_not be_new_record
      @topic.reload.last_updated_at.should == @topic.posts.first.created_at
    end
  
    base.it "sets topic's last_user_id" do
      @topic = post!
      @topic.should_not be_new_record
      @topic.reload.last_user.should == @topic.posts.first.user
    end

    base.it "increments Topic.count" do
      @creating_topic.should change { Topic.count }.by(1)
    end
    
    base.it "increments Post.count" do
      @creating_topic.should change { Post.count }.by(1)
    end
    
    base.it "increments cached site topics_count" do
      @creating_topic.should change { sites(:default).reload.topics_count }.by(1)
    end
    
    base.it "increments cached forum topics_count" do
      @creating_topic.should change { forums(:default).reload.topics_count }.by(1)
    end
    
    base.it "increments cached site posts_count" do
      @creating_topic.should change { sites(:default).reload.posts_count }.by(1)
    end
    
    base.it "increments cached forum posts_count" do
      @creating_topic.should change { forums(:default).reload.posts_count }.by(1)
    end
    
    base.it "increments cached user posts_count" do
      @creating_topic.should change { users(:default).reload.posts_count }.by(1)
    end
  end

  def post!
    @user.post forums(:default), new_topic(:default, @attributes).attributes
  end
end

describe User, "#post for users" do  
  include TopicCreatePostHelper
  
  it "ignores sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should_not be_sticky
  end
  
  it "ignores locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should_not be_locked
  end
end

describe User, "#post for moderators" do
  include TopicCreatePostHelper
  
  before do
    @user.stub!(:moderator_of?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should be_locked
  end
end

describe User, "#post for admins" do
  include TopicCreatePostHelper
  
  before do
    @user.admin = true
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    @topic = post!
    @topic.should_not be_new_record
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    @topic = post!
    @topic.should_not be_new_record
    @topic.should be_locked
  end
end

module TopicUpdatePostHelper
  def self.included(base)
    base.define_models
    
    base.before do
      @user  = users(:default)
      @topic = topics(:default)
      @attributes = {:body => 'booya'}
    end
  end
  
  def revise!
    @user.revise @topic, @attributes
  end
end

describe User, "#revise(topic) for users" do  
  include TopicUpdatePostHelper
  
  it "ignores sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should_not be_sticky
  end
  
  it "ignores locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should_not be_locked
  end
end

describe User, "#revise(topic) for moderators" do
  include TopicUpdatePostHelper
  
  before do
    @user.stub!(:moderator_of?).and_return(true)
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should be_locked
  end
end

describe User, "#revise(topic) for admins" do
  include TopicUpdatePostHelper
  
  before do
    @user.admin = true
  end
  
  it "sets sticky bit" do
    @attributes[:sticky] = 1
    revise!
    @topic.should be_sticky
  end
  
  it "sets locked bit" do
    @attributes[:locked] = true
    revise!
    @topic.should be_locked
  end
end

describe User, "#reply" do
  define_models
  
  before do
    @user  = users(:default)
    @topic = topics(:default)
    @creating_post = lambda { post! }
  end
  
  it "doesn't post if topic is locked" do
    @topic.locked = true; @topic.save
    @post = post!
    @post.should be_new_record
  end

  it "sets topic's last_updated_at" do
    @post = post!
    @topic.reload.last_updated_at.should == @post.created_at
  end

  it "sets topic's last_user_id" do
    Topic.update_all 'last_user_id = 3'
    @post = post!
    @topic.reload.last_user.should == @post.user
  end
  
  it "increments Post.count" do
    @creating_post.should change { Post.count }.by(1)
  end
  
  it "increments cached topic posts_count" do
    @creating_post.should change { topics(:default).reload.posts_count }.by(1)
  end
  
  it "increments cached forum posts_count" do
    @creating_post.should change { forums(:default).reload.posts_count }.by(1)
  end
  
  it "increments cached site posts_count" do
    @creating_post.should change { sites(:default).reload.posts_count }.by(1)
  end
  
  it "increments cached user posts_count" do
    @creating_post.should change { users(:default).reload.posts_count }.by(1)
  end

  def post!
    @user.reply topics(:default), 'duane, i think you might be color blind.'
  end
end