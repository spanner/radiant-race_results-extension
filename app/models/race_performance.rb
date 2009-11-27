class RacePerformance < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_instance, :class_name => 'RaceInstance'
  belongs_to :race_competitor
  belongs_to :category, :class_name => 'RaceCategory'
  belongs_to :club, :class_name => 'RaceClub'
  has_many :checkpoint_times, :class_name => 'RaceCheckpointTime'

  delegate :name, :reader, :to => :race_competitor
  
  before_validation_on_create :times_from_checkpoints
  validates_presence_of :race_competitor_id, :race_instance_id

  default_scope :order => 'elapsed_time DESC'

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
    {
      :conditions => ['race_category_id = ?', category.id]
    }
  }

  named_scope :eligible_for_category, lambda {|category|
    {
      :conditions => ['race_category_id in (?)', RaceCategory.within(category).map(&:id).join(',')]
    }
  }

  named_scope :in_club, lambda {|club|
    {
      :conditions => ["(race_club_id = :club) or (race_club_id IS NULL AND race_competitors.race_club_id = :club)", {:club => club.id}]
    }
  }

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
    started_at || race_instance.started_at || checkpoint_times.first.time
  end

  def finish
    finished_at || start + elapsed_time
  end

  def position
    race_instance.performances.quicker_than(time).count + 1
  end
  
  def elapsed_time
    read_attribute(:elapsed_time).to_timecode
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds)    # numbers will pass through unchanged. strings will be timecode-parsed
  end

protected

  def times_from_checkpoints
    # self.started_at ||= checkpoint_times.first.elapsed_time if checkpoint_times.any? && !race_instance.started_at
    # self.finished_at ||= checkpoint_times.last.elapsed_time if checkpoint_times.any? && !elapsed_time
    # self.elapsed_time ||= finished_at - started_at
  end
  
end

