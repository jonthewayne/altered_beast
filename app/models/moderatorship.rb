class Moderatorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum
  validates_presence_of :user_id, :forum_id
  validate :uniqueness_of_relationship
  validate :user_and_forum_in_same_site
  
protected
  def uniqueness_of_relationship
    if self.class.exists?(:user_id => user_id, :forum_id => forum_id)
      errors.add_to_base("Cannot add duplicate user/forum relation")
    end
  end
  
  def user_and_forum_in_same_site
    unless user.site_id == forum.site_id
      errors.add_to_base("User and Forum must be in the same Site.")
    end
  end
end
