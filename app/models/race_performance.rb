class RacePerformance < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_instance
  belongs_to :race_competitor
  belongs_to :race_category
  has_many :checkpoint_times, :class_name => 'RaceCheckpointTime'

  delegate :name, :reader, :club, :to => :competitor
  
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
  
  # named_scope :by_members_of, lambda {|club|
  #   club = RaceClub.find_by_name(club) unless club.is_a? RaceClub
  #   {
  #     :conditions => ["race_category_id in (#{eligible_categories.map{'?'}.join(',')})", *eligible_categories.map(&:id)]
  #   }
  # }

  named_scope :quicker_than, lambda { |seconds|
    {
      :conditions => ["elapsed_time < ?", seconds]
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
    pos = read_attribute(:position)
    if pos.nil? || pos.blank?
      pos = race_instance.performances.quicker_than(elapsed_time).count + 1
      write_attribute(:position, pos)
    end
    pos
  end
    
  def elapsed_time
    if s = read_attribute(:elapsed_time)
      s.to_timecode
    else
      ""
    end
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds) if time    # numbers will pass through unchanged. strings will be timecode-parsed
  end
  
  def time_at(checkpoint)
    checkpoint_times.time_at(checkpoint).first
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
    # true if we won a prize
  end
  
  def prize
    # report what prize was won, if any
  end
  
protected

  def times_from_checkpoints
    # self.started_at ||= checkpoint_times.first.elapsed_time if checkpoint_times.any? && !race_instance.started_at
    # self.finished_at ||= checkpoint_times.last.elapsed_time if checkpoint_times.any? && !elapsed_time
    # self.elapsed_time ||= finished_at - started_at
  end

end

