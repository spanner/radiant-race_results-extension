class Race < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :instances, :class_name => 'RaceInstance'
  has_many :records, :class_name => 'RaceRecord'

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_length_of :slug, :maximum => 100, :message => '{{count}}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'

  def latest
    instances.first   # they sort by start time desc
  end

  def in(name)
    instances.find_by_name(name)
  end

end

