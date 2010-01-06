require 'csv'

class RaceInstance < ActiveRecord::Base

  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :through => :performances, :source => :race_competitor
  has_many :categories, :through => :performances, :source => :race_category, :uniq => true

  has_many :finishers, :class_name => 'RacePerformance', :conditions => "race_performances.status_id >= 100"
  has_many :non_finishers, :class_name => 'RacePerformance', :conditions => "race_performances.status_id < 100"
  has_many :successful_competitors, :through => :finishers, :source => :race_competitor
  has_many :unsuccessful_competitors, :through => :non_finishers, :source => :race_competitor
  
  object_id_attr :filter, TextFilter
  has_attached_file :results,
                    :url => Radiant::Config["race_results.url"] ? Radiant::Config["race_results.url"] : "/:class/:id/:basename:no_original_style.:extension", 
                    :path => Radiant::Config["race_results.path"] ? Radiant::Config["race_results.path"] : ":rails_root/public/:class/:id/:basename:no_original_style.:extension"

  after_save :process_results_file

  validates_presence_of :name, :slug, :race
  validates_uniqueness_of :slug, :scope => :race_id
  validates_length_of :slug, :maximum => 100, :message => '{{count}}-character limit'
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|)$}, :message => 'not URL-friendly'
  default_scope :order => 'started_at DESC'
  
  named_scope :with_results, {:conditions => "results_file_name IS NOT NULL"}
  named_scope :without_results, {:conditions => "results_file_name IS NULL"}
  named_scope :past, {:conditions => ["started_at <= :when", {:when => Time.now}]}
  named_scope :future, {:conditions => ["started_at > :when", {:when => Time.now}], :order => "started_at ASC"}
  
  def to_param
    slug
  end
  
  def full_name
    "#{race.name} #{name}"
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
  
  def past?
    started_at <= Time.now
  end
  
  def future?
    started_at > Time.now
  end
  
  def has_results?
    performances.any?
  end
  
  def checkpoints
    # we will need to accommodate races whose checkpoints are different with each instance, but for now:
    race.checkpoints
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
      RaceInstance.transaction do
        performances.destroy_all
        race_data.each do |line|
          runner = normalize_fields(line)
          next if runner['name'].blank?

          runner['elapsed_time'] ||= "0"
          club = RaceClub.find_or_create_by_any_name(runner.delete('club')) unless runner['club'].blank? 
          competitor = RaceCompetitor.find_or_create_by_name_and_club(runner.delete('name'), club)
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
        
          headers.each do |key|
            value = runner[normalize(key)]
            if value && value.looks_like_duration? && cp = race.checkpoints.find_by_name(key)
              cp.times.create(:race_performance_id => performance.id, :elapsed_time => value)
            end
          end
        end
      end
    end
  end

  def read_results_file
    CSV.read(results.path)
  rescue
    nil
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
    squashed = value.strip.downcase
    squashed.gsub!(/\s+/, "_")
    squashed.gsub!(/\W+/, "")
    @@field_aliases[squashed] || squashed
  end
  
end

