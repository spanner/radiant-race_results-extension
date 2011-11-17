class RaceCheckpointTime < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_performance
  belongs_to :race_checkpoint
  delegate :race_instance, :category, :competitor, :club, :to => :race_performance
  delegate :name, :location, :description, :to => :race_checkpoint
  validates_presence_of :race_checkpoint, :race_performance

  alias :performance :race_performance
  alias :checkpoint :race_checkpoint
  
  # default_scope :include => [:race_performance, :race_checkpoint]
  before_save :calculate_interval   # position would be nice too but we may not have imported all the data at this stage
  
  named_scope :with_context, :include => [:race_performance, :race_checkpoint]
  named_scope :by_time, { :order => 'race_checkpoint_times.elapsed_time' }
  named_scope :by_interval, { :order => 'race_checkpoint_times.interval' }

  named_scope :single, lambda { |offset| 
    {
      :limit => 1,
      :offset => offset.to_i
    }
  }

  named_scope :in, lambda {|instance|
    {
      :joins => "INNER JOIN race_performances as performances ON race_checkpoint_times.race_performance_id = performances.id",  
      :conditions => ["performances.race_instance_id = ?", instance.id]
    }
  }
  
  named_scope :at_checkpoint, lambda {|checkpoint|
    {
      :conditions => ["race_checkpoint_id = ?", checkpoint.id]
    }
  }

  named_scope :ahead_of, lambda {|duration|
    {
      :conditions => ["race_checkpoint_times.elapsed_time IS NOT NULL AND race_checkpoint_times.elapsed_time > 0 AND race_checkpoint_times.elapsed_time < ?", duration]
    }
  }
  
  named_scope :quicker_than, lambda {|duration|
    {
      :conditions => ["race_checkpoint_times.interval IS NOT NULL AND race_checkpoint_times.interval > 0 AND race_checkpoint_times.interval < ?", duration]
    }
  }
  
  named_scope :other_than_finish, {
    :joins => "INNER JOIN race_checkpoints as checkpoints ON race_checkpoint_times.race_checkpoint_id = checkpoints.id",  
    :conditions => ["NOT checkpoints.name = ?", "Finish"]
  }
  
  def to_s
    time = read_attribute(:elapsed_time)
    if time && time != 0
      time.to_timecode
    else
      ""
    end
  end

  def position
    faster = self.class.in(race_instance).at_checkpoint(checkpoint).ahead_of(elapsed_time.seconds)
    faster.length + 1
  end
  
  def inverted_position
    race_instance.total_runners - position
  end

  def leg_position
    if !previous
      position
    elsif interval && interval.seconds > 0
      faster = self.class.in(race_instance).at_checkpoint(checkpoint).quicker_than(interval.seconds)
      faster.length + 1
    end
  end
  
  def inverted_leg_position
    race_instance.total_runners - leg_position
  end
  
  def elapsed_time
    if s = read_attribute(:elapsed_time)
      s.to_timecode
    else
      ""
    end
  end
  
  def time_in_seconds
    read_attribute(:elapsed_time)
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds)    # numbers will pass through unchanged. strings will be timecode-parsed
  end
  
  def interval
    if s = read_attribute(:interval)
      s.to_timecode
    else
      ""
    end
  end
  
  def interval_in_seconds
    read_attribute(:interval)
  end
  
  def previous
    performance.time_at(checkpoint.previous) if checkpoint.previous
  end
  
  def previous_position
    if previous
      previous.position
    else
      1
    end
  end
  
  def gain
    position - previous_position
  end

private

  def calculate_interval
    previous_time = previous.elapsed_time if previous
    previous_time ||= 0
    write_attribute(:interval, (elapsed_time - previous_time).seconds)
    save if changed?
  end

end

