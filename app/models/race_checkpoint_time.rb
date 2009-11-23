class RaceCheckpointTime < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :performance, :class_name => 'RacePerformance'
  belongs_to :checkpoint, :class_name => 'RaceCheckpoint'

  delegate :race_instance, :category, :competitor, :club, :to => :performance
  
  named_scope :at, lambda {|checkpoint|
    {
      :conditions => ["race_checkpoint_id = ?", checkpoint.id]
    } if checkpoint
  }

  named_scope :in, lambda {|instance|
    {
      :joins => "INNER JOIN race_performances as performances ON race_checkpoint_times.race_performance_id = performances.id",  
      :conditions => ["performances.race_instance_id = ?", instance.id]
    }
  }

  # for consistency, and to make plain that it is an interval not a datetime, the time logged at this checkpoint is stored as 'duration'
  
  named_scope :quicker_than, lambda {|duration|
    {
      :conditions => ["duration < ?", duration]
    }
  }

  def position
    checkpoint.times.in(race_instance).quicker_than(duration).count + 1
  end
  
  def previous
    performance.checkpoint_times.at(checkpoint.previous) if checkpoint.previous
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

end

