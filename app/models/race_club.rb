class RaceClub < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :class_name => 'RaceCompetitor'

end

