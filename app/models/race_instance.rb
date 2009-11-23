class RaceInstance < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race
  has_many :checkpoints, :class_name => 'RaceCheckpoint'
  has_many :race_instance_categories
  has_many :categories, :through => :race_instance_categories, :source => :race_category
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :through => :performances, :source => :race_competitor

  default_scope :order => 'started_at DESC'
  
  validates_presence_of :name, :slug, :started_at, :race
  validates_uniqueness_of :slug, :scope => :race_id
  validates_length_of :slug, :maximum => 100, :message => '{{count}}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'
  
  # on creation, checkpoints will need to copy from latest instance in an overridable way
  
  def checkpoint_before(cp)
    checkpoints.at(checkpoints.index(cp) - 1) if checkpoints.contain?(cp) and checkpoints.first != cp
  end

  def checkpoint_after(cp)
    checkpoints.at(checkpoints.index(cp) + 1) if checkpoints.contain?(cp) and checkpoints.last != cp
  end
  
  def winner
    performances.first.race_competitor
  end
  
  # this will need to changed to understand the category hierarchy
  
  def category_winner(category)
    category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
    performances.in_category(category).first.race_competitor if categories.include?(category)
  end
  
end

