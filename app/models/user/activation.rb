class User
  after_create :set_first_user_as_activated
  def set_first_user_as_activated
    activate! if site.nil? or site.users.size <= 1
  end
  
  def remember_token?
    active? && remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
end