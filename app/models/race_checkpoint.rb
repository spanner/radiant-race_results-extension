class RaceCheckpoint < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race_instance
  has_many :times, :class_name => 'RaceCheckpointTime'
  default_scope :order => :pos

  named_scope :in, lambda {|race|
    :conditions => ['race_id = ?', race.id]
  }

  def previous
    race.checkpoint_before(self)
  end

  def next
    race.checkpoint_after(self)
  end

end

