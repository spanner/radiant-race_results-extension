class RaceClub < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :class_name => 'RaceCompetitor'
  has_many :aliases, :class_name => 'RaceClubAlias'

  validates_presence_of :name
  
  named_scope :by_name_or_alias, lambda { |name|
    {
      :select => 'race_clubs.*',
      :joins => "INNER JOIN race_club_aliases AS aliases ON aliases.race_club_id = race_clubs.id",
      :conditions => ["race_clubs.name = :name OR aliases.name = :name", {:name => name}],
      :group => 'race_clubs.id'
    }
  }
  def self.find_by_name_or_alias(name)
    name.gsub(/_/, ' ')
    clubs = self.by_name_or_alias(name)
    clubs.first if clubs.any?
  end

  def self.find_or_create_by_name_or_alias(name)
    name.gsub(/_/, ' ')
    find_by_name_or_alias(name) || self.create(:name => name)
  end

end

