class RaceRecord < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :race
  belongs_to :race_competitor
  belongs_to :race_category

  # these associations are only populated in the relatively rare case where the record is part of one of our result sets
  belongs_to :race_instance
  belongs_to :race_performance

  def elapsed_time
    read_attribute(:elapsed_time).to_timecode
  end
  
  def elapsed_time=(time)
    write_attribute(:elapsed_time, time.seconds) if time    # numbers will pass through unchanged. strings will be timecode-parsed
  end

end

