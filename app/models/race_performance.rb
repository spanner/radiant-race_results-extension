class RacePerformance < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_instance, :class_name => 'RaceInstance'
  belongs_to :competitor, :class_name => 'RaceCompetitor'
  belongs_to :category, :class_name => 'RaceCategory'
  belongs_to :club, :class_name => 'RaceClub'
  has_many :checkpoint_times, :class_name => 'RaceCheckpointTime'
  
  before_validation_on_create :times_from_checkpoints
  validates_presence_of :competitor, :race_instance
  
  named_scope :in, lambda {|race_instance|
    :conditions => ['race_instance_id = ?', race_instance.id]
  }
  
  named_scope :in_race, lambda {|race|
    :conditions => ['race_instance_id in (?)', race.instances.map(&:id).join(',')]
  }

  named_scope :in_category, lambda {|category|
    :conditions => ['race_category_id = ?', category.id]
  }

  named_scope :in_club, lambda {|club|
    :conditions => ["(race_club_id = :club) or (race_club_id IS NULL AND race_competitors.race_club_id = :club)", {:club => club.id}]
  }

  named_scope :completed, {
    :conditions => 'status_id >= 100'
  }
  
  named_scope :incomplete, {
    :conditions => 'status_id < 100'
  }
  
  named_scope :quicker_than, lambda { |time| 
    :conditions => ["duration < ?", time]
  }

  def start
    started_at || race_instance.started_at || checkpoint_times.first.time
  end

  def finish
    finished_at || start + duration
  end

  def position
    race_instance.performances.quicker_than(time).count + 1
  end
  
protected

  def times_from_checkpoints
    self.started_at ||= checkpoint_times.first.duration
    self.finished_at ||= checkpoint_times.last.duration
  end
  
end

