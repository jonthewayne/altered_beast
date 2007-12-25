class User < ActiveRecord::Base
  concerned_with :validation, :states, :activation

  belongs_to :site
  validates_presence_of :site_id
  
  has_many :posts
  has_many :topics
  
  has_many :moderatorships
  has_many :moderated_forums, :through => :moderatorships, :source => :forum
  
  def moderator_of?(forum)
    Moderatorship.exists?(:user_id => id, :forum_id => forum.id)
  end
  
  attr_readonly :posts_count
end
