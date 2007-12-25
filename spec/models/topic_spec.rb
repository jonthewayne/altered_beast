require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  define_models

  it "updates forum_id for posts when topic forum is changed" do
    topics(:default).update_attribute :forum, forums(:other)
    posts(:default).reload.forum.should == forums(:other)
  end
  
  it "leaves other topic post #forum_ids alone when updating forum" do
    topics(:default).update_attribute :forum, forums(:other)
    posts(:other).reload.forum.should == forums(:default)
  end
  
  it "doesn't update last_updated_at when updating topic" do
    current_date = topics(:default).last_updated_at
    topics(:default).last_updated_at.should == current_date
  end

  [:title, :user_id, :forum_id].each do |attr|
    it "validates presence of #{attr}" do
      t = new_topic(:default)
      t.send("#{attr}=", nil)
      t.should_not be_valid
      t.errors.on(attr).should_not be_nil
    end
  end
  
  it "selects posts" do
    topics(:default).posts.should == [posts(:default)]
  end

  it "creates unsticky topic by default" do
    t = new_topic(:default)
    t.body = 'foo'
    t.sticky = nil
    t.save!
    t.should_not be_new_record
    t.should_not be_sticky
  end
  
  it "recognizes '1' as sticky" do
    topics(:default).should_not be_sticky
    topics(:default).sticky = 1
    topics(:default).should be_sticky
  end

  it "#hit! increments hits counter" do
    lambda { topics(:default).hit! }.should change { topics(:default).reload.hits }.by(1)
  end
  
  it "should know paged? status" do
    topics(:default).posts_count = 0
    topics(:default).should_not be_paged
    topics(:default).posts_count = Post.per_page + 5
    topics(:default).should be_paged
  end
  
  it "knows last page number based on posts count" do
    {0.0 => 1, 0.5 => 1, 1.0 => 1, 1.5 => 2}.each do |multiplier, last_page|
      topics(:default).posts_count = (Post.per_page.to_f * multiplier).ceil
      topics(:default).last_page.should == last_page
    end
  end
  
  it "doesn't allow new posts for locked topics" do
    @topic = topics(:default)
    @topic.locked = true ; @topic.save
    @post = @topic.post!('booya', @topic.user)
    @post.should be_new_record
    @post.errors.on(:base).should == 'Topic is locked'
  end
end

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
    
    base.it "increments cached forum topics_count" do
      @creating_topic.should change { forums(:default).reload.topics.size }.by(1)
    end
    
    base.it "increments cached forum posts_count" do
      @creating_topic.should change { forums(:default).reload.posts.size }.by(1)
    end
    
    base.it "increments cached user posts_count" do
      @creating_topic.should change { users(:default).reload.posts.size }.by(1)
    end
  end

  def post!
    forums(:default).topics.post!(new_topic(:default, @attributes).attributes, @user)
  end
end

describe Topic, ".post! for users" do  
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

describe Topic, ".post! for moderators" do
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

describe Topic, ".post! for admins" do
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

describe Topic, "#post!" do
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
    @creating_post.should change { topics(:default).reload.posts.size }.by(1)
  end
  
  it "increments cached forum posts_count" do
    @creating_post.should change { forums(:default).reload.posts.size }.by(1)
  end
  
  it "increments cached user posts_count" do
    @creating_post.should change { users(:default).reload.posts.size }.by(1)
  end

  def post!
    topics(:default).post!('duane, i think you might be color blind.', @user)
  end
end

describe Topic, "being deleted" do
  define_models

  before do
    @topic = topics(:default)
    @deleting_topic = lambda { @topic.destroy }
  end
  
  it "deletes posts" do
    post = posts(:default).reload
    @deleting_topic.call
    lambda { post.reload }.should raise_error(ActiveRecord::RecordNotFound)
  end
  
  it "decrements Topic.count" do
    @deleting_topic.should change { Topic.count }.by(-1)
  end
  
  it "decrements Post.count" do
    @deleting_topic.should change { Post.count }.by(-1)
  end
  
  it "decrements cached forum topics_count" do
    @deleting_topic.should change { forums(:default).reload.topics.size }.by(-1)
  end
  
  it "decrements cached forum posts_count" do
    @deleting_topic.should change { forums(:default).reload.posts.size }.by(-1)
  end
  
  it "decrements cached user posts_count" do
    @deleting_topic.should change { users(:default).reload.posts.size }.by(-1)
  end
end

describe Topic, "being moved to another forum" do
  define_models
  
  before do
    @forum     = forums(:default)
    @new_forum = forums(:other)
    @topic     = topics(:default)
    @moving_forum = lambda { @topic.forum = @new_forum ; @topic.save! }
  end
  
  it "decrements old forums cached topics_count" do
    @moving_forum.should change { @forum.reload.topics.size }.by(-1)
  end
  
  it "decrements old forums cached posts_count" do
    @moving_forum.should change { @forum.reload.posts.size }.by(-1)
  end
  
  it "increments new forums cached topics_count" do
    @moving_forum.should change { @new_forum.reload.topics.size }.by(1)
  end
  
  it "increments new forums cached posts_count" do
    @moving_forum.should change { @new_forum.reload.posts.size }.by(1)
  end
  
  it "moves posts to new forum" do
    @topic.posts.each { |p| p.forum.should == @forum }
    @moving_forum.call
    @topic.posts.each { |p| p.reload.forum.should == @new_forum }
  end
end