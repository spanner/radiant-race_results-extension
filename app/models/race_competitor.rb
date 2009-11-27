class RaceCompetitor < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :reader
  belongs_to :club, :class_name => 'RaceClub'
  has_many :performances, :class_name => 'RacePerformance'

end

