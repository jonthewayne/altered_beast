class Post < ActiveRecord::Base
  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic, :counter_cache => true
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  # topic's site (set by callback)
  belongs_to :site, :counter_cache => true
  
  validates_presence_of :user_id, :site_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
  after_destroy :update_cached_fields

  attr_accessible :body

  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
  end

protected
  def update_cached_fields
    topic.update_cached_post_fields(self)
  end
  
  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic && topic.locked?
  end
end