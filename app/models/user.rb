class User < ActiveRecord::Base
  include User::Validation, User::States, User::Activation
end
