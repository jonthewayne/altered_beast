class CreatePermalinks < ActiveRecord::Migration
  def self.up
    transaction do
      User.paginated_each do |user|
        User.update_all ['permalink = ?', PermalinkFu.escape(user.login)], ['id = ?', user.id]
      end
      Forum.paginated_each do |forum|
        Forum.update_all ['permalink = ?', PermalinkFu.escape(forum.name)], ['id = ?', forum.id]
      end
      Topic.paginated_each do |topic|
        Topic.update_all ['permalink = ?', PermalinkFu.escape(topic.title)], ['id = ?', topic.id]
      end
    end
  end

  def self.down
  end
end
