module ForumsHelper
  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false unless logged_in? && forum.recent_topic
    return forum.recent_topic.replied_at > (session[:forums][forum.id] || last_active)
  end
end
