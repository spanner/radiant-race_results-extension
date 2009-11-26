require 'csv'

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

  has_attached_file :results  
  after_save :process_results_file

  default_scope :order => 'started_at DESC'

  validates_presence_of :name, :slug, :started_at, :race
  validates_uniqueness_of :slug, :scope => :race_id
  validates_length_of :slug, :maximum => 100, :message => '{{count}}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'

  def name
    "#{race.name}: #{slug}"
  end
  
  def checkpoint_before(cp)
    checkpoints.at(checkpoints.index(cp) - 1) if checkpoints.contain?(cp) and checkpoints.first != cp
  end

  def checkpoint_after(cp)
    checkpoints.at(checkpoints.index(cp) + 1) if checkpoints.contain?(cp) and checkpoints.last != cp
  end
  
  def performance_by(competitor)
    
  end
  
  def performance_at(position)
    
  end
  
  def winning_performance(category=nil)
    if category
      category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
      performances.eligible_for_category(category).first if categories.include?(category)
    else
      performances.first
    end
  end
  
  def winner(category=nil)
    winning_performance(category).race_competitor
  end
    
  def top(count=20)
    performances.top(count)
  end
  
  def category_top(count=5)
    performances.eligible_for_category(category).top(count)
  end
  
protected

  def process_results_file
    # need better flagging of new results: use dirty and process while saving?
    if (results && results.path)
      csv_data = CSV.read(results.path)
      headers = csv_data.shift.map {|i| i.to_s }
      race_data = csv_data.map {|row| row.map {|cell| cell.to_s } }.map {|row| Hash[*headers.zip(row).flatten] } # build AoA and then hash the second level
    
      RaceInstance.transaction do
        performances.destroy_all
        race_data.each do |result|
        
        end
      end
    end
  end

end

