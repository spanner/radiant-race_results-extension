class RaceClub < ActiveRecord::Base
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :performances, :class_name => 'RacePerformance'
  has_many :competitors, :class_name => 'RaceCompetitor'

  has_many :other_names, :class_name => 'RaceClubAlias'
  accepts_nested_attributes_for :other_names, :allow_destroy => true

  validates_presence_of :name
  default_scope :order => 'name ASC'
  
  named_scope :by_name_or_alias, lambda { |name|
    {
      :select => 'race_clubs.*',
      :joins => "LEFT JOIN race_club_aliases AS aliases ON aliases.race_club_id = race_clubs.id",
      :conditions => ["race_clubs.name LIKE :name OR aliases.name LIKE :name", {:name => "#{normalize_name(name)}%"}],
      :group => "race_clubs.id"
    }
  }
  
  def self.find_by_any_name(name)
    by_name_or_alias(name).first
  end

  def self.find_or_create_by_any_name(name=nil)
    name = normalize_name(name)
    return if name.blank?
    return if %w{unattached ua u/a}.include? name.downcase
    unless club = find_by_any_name(name) 
      club = new(:name => name)
      club.save!
    end
    club
  end
  
  #TODO make this a lot more UTF-friendly:
  # strip control characters and excel mmska without losing accents and symbols?
  
  def self.normalize_name(name="")
    name.gsub!(/\B&\B/, "and")
    name.gsub!(/\s+/, " ")
    name.gsub!(/[^A-Za-z -,]/, "")
    name.strip
  end

end
