class Post < ActiveRecord::Base
  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic, :counter_cache => true
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  attr_accessible :body

protected
  # using count isn't ideal but it gives us correct caches each time
  def update_cached_fields
    #Forum.update_all ['posts_count = ?', Post.count(:id, :conditions => {:forum_id => forum_id})], ['id = ?', forum_id]
    #User.update_posts_count(user_id)
    topic.update_cached_post_fields(self)
  end
  
  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic && topic.locked?
  end
end