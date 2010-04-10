class RaceCompetitor < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :reader
  belongs_to :race_club#, :class_name => 'RaceClub'
  has_many :performances, :class_name => 'RacePerformance'
  default_scope :order => 'name ASC'
  
  def club
    race_club
  end
  
  def self.find_or_create_by_name_and_club(name="", club=nil)
    return if name.blank?
    club_id = club.nil? ? nil : club.id
    find_or_create_by_name_and_race_club_id(name, club_id)
  end
end

