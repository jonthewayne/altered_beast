class User < ActiveRecord::Base
  include User::Validation, User::States, User::Activation

  belongs_to :site
  validates_presence_of :site_id
end
