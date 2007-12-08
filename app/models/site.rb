class Site < ActiveRecord::Base
  has_many :users, :conditions => {:state => 'active'}
  has_many :all_users, :class_name => 'User'
  
  def self.main
    @main ||= find :first, :conditions => {:host => ''}
  end
  
  def self.find_by_host(name)
    return nil if name.nil?
    name.strip!
    name.sub! /^www\./, ''
    sites = find :all, :conditions => ['host = ? or host = ?', name, '']
    sites.reject { |s| s.default? }.first || sites.first
  end
  
  def default?
    host.blank?
  end
end