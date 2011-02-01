class RaceCheckpointTime < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :performance, :class_name => 'RacePerformance'
  belongs_to :checkpoint, :class_name => 'RaceCheckpoint'
  # delegate :race_instance, :category, :competitor, :club, :to => :performance

  # validates_presence_of :checkpoint, :performance
  
  named_scope :at_checkpoint, lambda {|checkpoint|
    {
      :conditions => ["race_checkpoint_id = ?", checkpoint.id]
    }
  }

  named_scope :time_in, lambda {|instance|
    {
      :joins => "INNER JOIN race_performances as performances ON race_checkpoint_times.race_performance_id = performances.id",  
      :conditions => ["performances.race_instance_id = ?", instance.id]
    }
  }

  named_scope :quicker_than, lambda {|duration|
    {
      :conditions => ["elapsed_time < ?", duration]
    }
  }

  def position
    checkpoint.times.in(race_instance).quicker_than(duration).count + 1
  end
  
  def elapsed_time
    if s = read_attribute(:elapsed_time)
      s.to_timecode
    else
      ""
    end
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds)    # numbers will pass through unchanged. strings will be timecode-parsed
  end
  
  def previous
    performance.checkpoint_times.at_checkpoint(checkpoint.previous) if checkpoint.previous
  end
  
  def previous_position
    if previous
      previous.position
    else
      1
    end
  end
  
  def gain
    sprintf('+%d', position - previous_position)
  end

end

