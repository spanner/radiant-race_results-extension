class RaceCompetitor < ActiveRecord::Base
  
  has_site if respond_to? :has_site
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :reader
  belongs_to :club, :class_name => 'RaceClub' # can be overridden by club associated with a particular performance
  has_many :performances, :class_name => 'RacePerformance'

end

