class User < ActiveRecord::Base
  concerned_with :validation, :states, :activation

  belongs_to :site
  validates_presence_of :site_id
  
  has_many :posts
  has_many :topics
  
  def moderator_of?(forum)
    admin?
  end
  
  attr_readonly :posts_count
end
