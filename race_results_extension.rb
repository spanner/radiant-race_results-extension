# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

require "radiant-race_results-extension"

class RaceResultsExtension < Radiant::Extension
  version RadiantRaceResultsExtension::VERSION
  description RadiantRaceResultsExtension::DESCRIPTION
  url RadiantRaceResultsExtension::URL
  
  extension_config do |config|
    config.after_initialize do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.singular /(alias)$/i, 'alias'
      end
    end
  end
  
  def activate
    require 'duration_extensions'                   # string to duration and vice versa
    RacePage.send :include, RaceTags
    
    unless defined? admin.race
      Radiant::AdminUI.send :include, RaceAdminUI
      admin.race = Radiant::AdminUI.load_default_race_regions
      admin.race_instance = Radiant::AdminUI.load_default_race_instance_regions
      admin.race_club = Radiant::AdminUI.load_default_race_club_regions
      admin.race_competitor = Radiant::AdminUI.load_default_race_competitor_regions
    end
    
    tab("Races") do
      add_item "Races", "/admin/races"
      add_item 'Competitors', '/admin/race_competitors'
      add_item 'Clubs', '/admin/race_clubs'
    end
  end
  
  def deactivate
  end
end
