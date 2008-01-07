class User < ActiveRecord::Base
  concerned_with :validation, :states, :activation

  belongs_to :site, :counter_cache => true
  validates_presence_of :site_id
  before_validation { |u| u.display_name = u.login if u.display_name.blank? }
  
  has_many :posts
  has_many :topics
  
  has_many :moderatorships, :dependent => :delete_all
  has_many :moderated_forums, :through => :moderatorships, :source => :forum
  
  has_many :monitorships, :dependent => :delete_all
  has_many :monitored_topics, :through => :monitorships, :source => :topic, :conditions => {"#{Monitorship.table_name}.active" => true}
  
  def moderator_of?(forum)
    Moderatorship.exists?(:user_id => id, :forum_id => forum.id)
  end
  
  attr_readonly :posts_count, :last_seen_at

  # this is used to keep track of the last time a user has been seen (reading a topic)
  # it is used to know when topics are new or old and which should have the green
  # activity light next to them
  #
  # we cheat by not calling it all the time, but rather only when a user views a topic
  # which means it isn't truly "last seen at" but it does serve it's intended purpose
  #
  # This is now also used to show which users are online... not at accurate as the
  # session based approach, but less code and less overhead.
  def seen!
    now = Time.now.utc
    self.class.update_all ['last_seen_at = ?', now], ['id = ?', id]
    write_attribute :last_seen_at, now
  end
end
