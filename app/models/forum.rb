class Forum < ActiveRecord::Base
  acts_as_list

  validates_presence_of :name
  
  belongs_to :site
  def moderators() [] end
  def topics() [] end
  def posts() [] end
  def recent_topic() nil end
  def recent_post() nil end

  # retrieves forums ordered by position
  def self.find_ordered(options = {})
    find :all, options.update(:order => 'position')
  end
end
