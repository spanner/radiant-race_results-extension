# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class RaceResultsExtension < Radiant::Extension
  version "1.0"
  description "Makes easy the uploading, analysis and display of race results. Built for fell races but should work for most timed or score events."
  url "http://spanner.org/radiant/race_results"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :races do |race|
        race.resources :race_instances, :has_many => [:race_performances]
      end
      admin.resources :race_clubs
      admin.resources :race_competitors
    end
    
    # public interface is read-only and uses slugs for url-friendliness (and seo)
    map.races '/races', :controller => 'races', :action => 'index'
    map.race '/races/:slug', :controller => 'races', :action => 'show'
    map.results '/results', :controller => 'race_instances', :action => 'index'

    map.race_instance '/races/:race_slug/:slug', :controller => 'race_instances', :action => 'show'
    map.race_club '/races/:race_slug/:slug/club/:club', :controller => 'race_instances', :action => 'show'
    map.race_category '/races/:race_slug/:slug/cat/:cat', :controller => 'race_instances', :action => 'show'

    map.race_performance '/races/:race_slug/:slug/p/:id', :controller => 'race_performances', :action => 'show'
    
    # map.resources :race_clubs
    # map.resources :race_competitors
  end
  
  extension_config do |config|
    config.gem 'paperclip', :source => 'http://gemcutter.org'
    config.after_initialize do
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.singular /(alias)$/i, 'alias'
      end
    end
  end
  
  def activate
    require 'duration_extensions'                   # string to duration and vice versa
    Page.send :include, RaceResults::RaceTags
    
    unless defined? admin.race
      Radiant::AdminUI.send :include, RaceResults::AdminUI
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
