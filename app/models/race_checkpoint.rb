class RaceCheckpoint < ActiveRecord::Base

  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race
  acts_as_list :scope => :race_id
  has_many :times, :class_name => 'RaceCheckpointTime'

  default_scope :order => :position

  named_scope :in, lambda {|race|
    {
      :conditions => ['race_id = ?', race.id]
    }
  }
  
  def previous
    race.checkpoint_before(self)
  end

  def next
    race.checkpoint_after(self)
  end

  def self.find_by_normalized_name(name)
    find_by_name(name.gsub(/\s+/, "_").downcase)
  end
  
  def leading_time(instance)
    self.times.in(instance).first.time_in_seconds
  end

  def median_time(instance)
    count = self.times.in(instance).count
    if count && count !=0
      @median = self.times.in(instance).ordered.single(count/2).first.time_in_seconds
    else
      0
    end
  end

end

