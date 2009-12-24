require 'csv'

class RaceInstance < ActiveRecord::Base

  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race
  has_many :checkpoints, :class_name => 'RaceCheckpoint'
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :through => :performances, :source => :race_competitor
  has_many :categories, :through => :performances, :source => :race_category, :uniq => true

  has_many :finishers, :class_name => 'RacePerformance', :conditions => "race_performances.status_id >= 100"
  has_many :non_finishers, :class_name => 'RacePerformance', :conditions => "race_performances.status_id < 100"
  has_many :successful_competitors, :through => :finishers, :source => :race_competitor
  has_many :unsuccessful_competitors, :through => :non_finishers, :source => :race_competitor
  
  has_attached_file :results  
  after_post_process :process_results_file    # this probably ought to move into a paperclip processor

  default_scope :order => 'started_at DESC'

  validates_presence_of :name, :slug, :race
  validates_uniqueness_of :slug, :scope => :race_id
  validates_length_of :slug, :maximum => 100, :message => '{{count}}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'

  object_id_attr :filter, TextFilter
  
  def full_name
    "#{race.name}: #{name}"
  end
  
  def path
    "#{race.slug}/#{slug}"
  end
  
  def nice_start_time
    return unless started_at
    if started_at.min == 0
      started_at.to_datetime.strftime("%-1I%p").downcase
    else
      started_at.to_datetime.strftime("%-1I:%M%p").downcase
    end
  end
  
  def nice_start_date
    started_at.to_datetime.strftime("%B %e %Y") if started_at
  end
  
  def has_results?
    performances.any?
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
      performances.completed.eligible_for_category(category).first if category_present?(category)
    else
      performances.completed.first
    end
  end
  
  def winner(category=nil)
    if perf = winning_performance(category)
      perf.competitor
    end
  end
    
  def top(count=20)
    performances.top(count)
  end
  
  def category_top(category, count=5)
    performances.eligible_for_category(category).top(count) if category_present?(category)
  end
  
  def category_present?(category)
    categories.include?(category)
  end
  
protected
  
  def process_results_file
    if csv_data = read_results_file
      headers = csv_data.shift.map(&:to_s)
      race_data = csv_data.map {|row| row.map {|cell| cell.to_s } }.map {|row| Hash[*headers.zip(row).flatten] } # build AoA and then hash the second level
      Rails.logger.warn "^^  importing race data: #{race_data.size} lines"
      RaceInstance.transaction do
        performances.destroy_all
        race_data.each do |line|
          runner = normalize_fields(line)
          runner['time'] ||= "0"
          club = RaceClub.find_or_create_by_name_or_alias(runner.delete('club'))
          competitor = RaceCompetitor.find_or_create_by_name_and_race_club_id(runner.delete('name'), club.id)
          category = RaceCategory.find_or_create_by_normalized_name(runner.delete('category'))
          competitor.update_attribute(:gender, category.gender) unless competitor.gender
          status = RacePerformanceStatus.from_time(runner['elapsed_time'])
          performance = self.performances.create!({
            :position => runner.delete('position'),
            :competitor => competitor,
            :category => category,
            :elapsed_time => runner.delete('elapsed_time'),
            :status_id => status.id
          })
          
          # loop on headers to keep checkpoints in order
          headers.each do |key|
            value = runner[normalize(key)]
            if value && value.looks_like_duration?
              cp = checkpoints.find_or_create_by_name(key)
              cp.times.create(:race_performance_id => performance.id, :elapsed_time => value)
            end
          end
        end
      end
    end
  end

  def read_results_file
    CSV.read(results.path)
  end
  
  @@field_aliases = {
    'cat' => 'category',
    'time' => 'elapsed_time',
    'finish' => 'elapsed_time',
    'pos' => 'position'
  }
  
  def normalize_fields(line)
    line.keys.each do |key|
      line[normalize(key)] = line.delete(key)
    end
    line
  end
  
  def normalize(value)
    squashed = value.gsub(/\s+/, "_").downcase
    @@field_aliases[squashed] || squashed
  end
  
end

