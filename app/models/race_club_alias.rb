class RaceClubAlias < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :club, :class_name => 'RaceClub'

  validates_presence_of :name

end

