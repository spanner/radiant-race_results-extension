require 'enumerator'

class RacePerformance < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_instance
  belongs_to :race_competitor
  belongs_to :race_category
  has_many :checkpoint_times, :class_name => 'RaceCheckpointTime', :dependent => :destroy

  delegate :name, :reader, :club, :to => :competitor
  delegate :race, :to => :race_instance
  
  before_validation_on_create :times_from_checkpoints
  validates_presence_of :race_competitor_id, :race_instance_id
  
  default_scope :order => :elapsed_time

  # has_many through doesn't work with a foreign_key setting, so we do the readable names here instead
  alias :competitor :race_competitor
  alias :competitor= :race_competitor=
  alias :category :race_category
  alias :category= :race_category=
  
  named_scope :top, lambda {|count|
    {
      :order => 'elapsed_time DESC',
      :limit => count
    }
  }

  named_scope :by, lambda {|race_competitor|
    {
      :conditions => ['race_competitor_id = ?', race_competitor.id]
    }
  }
  
  named_scope :in, lambda {|race_instance|
    {
      :conditions => ['race_instance_id = ?', race_instance.id]
    }
  }

  named_scope :in_race, lambda {|race|
    {
      :conditions => ['race_instance_id in (?)', race.instances.map(&:id).join(',')]
    }
  }

  named_scope :in_category, lambda {|category|
    category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
    {
      :conditions => ['race_category_id = ?', category.id]
    }
  }

  named_scope :eligible_for_category, lambda {|category|
    category = RaceCategory.find_by_name(category) unless category.is_a? RaceCategory
    eligible_categories = RaceCategory.within(category)
    {
      :conditions => ["race_category_id in (#{eligible_categories.map{'?'}.join(',')})", *eligible_categories.map(&:id)]
    }
  }
  
  named_scope :by_members_of, lambda { |club|
    club = RaceClub.find_by_name(club) unless club.is_a? RaceClub
    {
      :select => 'race_performances.*',
      :joins => "LEFT JOIN race_competitors AS competitors ON race_performances.race_competitor_id = competitors.id",
      :conditions => ["competitors.race_club_id = ?", club.id]
    }
  }

  named_scope :quicker_than, lambda { |seconds|
    {
      :conditions => ["elapsed_time IS NOT NULL AND elapsed_time > 0 AND elapsed_time < ?", seconds]
    }
  }
  
  named_scope :finishing_between, lambda { |bottom, top|
    bottom, top = [top, bottom] if bottom > top
    {
      :conditions => ["position > ? AND position < ?", bottom, top]
    }
  }

  named_scope :completed, {
    :conditions => 'status_id >= 100'
  }
  
  named_scope :incomplete, {
    :conditions => 'status_id < 100'
  }

  def start
    started_at || race_instance.started_at || checkpoint_times.first.elapsed_time
  end

  def finish
    finished_at || start + elapsed_time
  end

  def position
    read_attribute(:position) || calculate_position
  end
  
  def calculate_position
    update_attribute(:position, race_instance.performances.quicker_than(time_in_seconds).count + 1)
    position
  end
  
  def prizes
    read_attribute(:prizes) || calculate_prizes
  end
  
  def calculate_prizes
    prizelist = []
    positions.each do |cat,pos| 
      prizelist << "#{pos.ordinalize} #{cat}" if pos <= 3
    end
    update_attribute(:prizes, prizelist.join(', '))
    prizes
  end
  
  def positions
    race_instance.categories.containing(category).inject({}) { |h, cat| h.merge( { cat.name => position_in(cat) } ) }
  end
  
  def position_in(cat)
    race_instance.performances.eligible_for_category(cat).quicker_than(time_in_seconds).count + 1
  end
  
  def sparkline_positions
    checkpoint_times.map(&:inverted_leg_position)
  end
  
  def neighbourhood(spread=3)
    race_instance.performances.finishing_between(self.position.to_i - spread, self.position.to_i + spread)
  end
  
  def neighbours(spread=3)
    neighbourhood(spread) - [self]
  end
  
  def time_in_seconds
    read_attribute(:elapsed_time)
  end
  
  def elapsed_time
    if s = time_in_seconds
      s.to_timecode
    else
      ""
    end
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds) if time    # numbers will pass through unchanged. strings will be timecode-parsed
  end
  
  def time_at(checkpoint)
    cpt = checkpoint_times.at_checkpoint(checkpoint)
    cpt.first if cpt.any?
  end

  def splits
    self.checkpoint_times.each_with_object({}) do |cpt, hsh| 
      hsh[cpt.race_checkpoint_id] = cpt.elapsed_time
    end
  end
  
  def split_times
    @split_times ||= race_instance.checkpoints.map{ |cp| self.time_at(cp) }
  end

  def split_seconds
    @split_seconds ||= split_times.map{ |st| st.time_in_seconds if st }
  end

  def status
    RacePerformanceStatus.find(self.status_id)
  end
  def status=(value)
    self.status_id = value.id
  end
  def finished?
     status == RacePerformanceStatus["Finished"]
  end
    
  def prized?
    true if prizes.any?
  end
  
  def club_name
    self.club ? self.club.name : 'unattached'
  end
  
  def as_json(options={})
    json = {
      :id => self.id,
      :pos => self.position,
      :name => self.name,
    }
    splits = []
    baseline = case options[:vs]
    when 'median'
      race_instance.median_checkpoint_times
    when 'leader'
      race_instance.winning_performance.split_seconds
    when RacePerformance
      options[:vs].split_seconds.dup
    else
      nil
    end
    if baseline
      splits = self.split_seconds.map{ |cpt| 
        base = baseline.shift # we need to step through the baseline even if this cp is missing
        base - cpt if cpt && base
      }
    else
      splits = self.split_seconds
    end
    intervals = race_instance.fastest_checkpoint_legs
    carry = 0
    json[:splits] = splits.map{|t| [carry += intervals.shift, t]}
    json
  end
  
protected

  def times_from_checkpoints
    # self.started_at ||= checkpoint_times.first.elapsed_time if checkpoint_times.any? && !race_instance.started_at
    # self.finished_at ||= checkpoint_times.last.elapsed_time if checkpoint_times.any? && !elapsed_time
    # self.elapsed_time ||= finished_at - started_at
  end
  
  def recalculate_positions
    position(true)
    prizes(true)
  end
  
  def record_finish_checkpoint_time
    unless self.elapsed_time.blank?
      cp = self.race.checkpoints.find_by_name('Finish')
      cpt = self.checkpoint_times.find_or_create_by_race_checkpoint_id(cp.id)
      cpt.elapsed_time = self.elapsed_time
      cpt.save if cpt.changed?
    end
  end

end

