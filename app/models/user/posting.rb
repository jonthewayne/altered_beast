class User
  # Creates new topic and post.
  # Only..
  #  - sets sticky/locked bits if you're a moderator or admin 
  #  - changes forum_id if you're an admin
  #
  def post(forum, attributes)
    attributes.symbolize_keys!
    returning Topic.new(attributes) do |topic|
      if admin? || moderator_of?(forum)
        topic.sticky, topic.locked = attributes[:sticky], attributes[:locked]
      end
      topic.forum = forum
      topic.user  = self
      topic.save
    end
  end

  def reply(topic, body)
    returning topic.posts.build(:body => body) do |post|
      post.site  = topic.site
      post.forum = topic.forum
      post.user  = self
      post.save
    end
  end
end