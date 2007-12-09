class Site < ActiveRecord::Base
  has_many :users, :conditions => {:state => 'active'}
  has_many :all_users, :class_name => 'User'
  
  validates_presence_of   :name
  validates_uniqueness_of :host
  
  def host=(value)
    write_attribute :host, value.to_s.downcase
  end
  
  def self.main
    @main ||= find :first, :conditions => {:host => ''}
  end
  
  def self.find_by_host(name)
    return nil if name.nil?
    name.downcase!
    name.strip!
    name.sub! /^www\./, ''
    sites = find :all, :conditions => ['host = ? or host = ?', name, '']
    sites.reject { |s| s.default? }.first || sites.first
  end
  
  def default?
    host.blank?
  end
end