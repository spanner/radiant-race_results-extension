# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class RaceResultsExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://spanner.org/radiant/race_results"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :races do |race|
        race.resources :race_checkpoints
        race.resources :race_instances, :has_many => [:race_performances]
        race.resources :race_categories, :has_many => [:race_performances]
        race.resources :race_performances, :has_many => [:race_checkpoint_times]
      end
      admin.resources :race_competitors do |runner|
        runner.resources :race_performances
      end
      admin.resources :race_clubs do |runner|
        runner.resources :race_performances
      end
    end
  end
  
  def activate
    admin.tabs.add "Races", "/admin/races", :after => "Layouts", :visibility => [:all]
    admin.tabs['Races'].add_link('races', '/admin/races')
    admin.tabs['Races'].add_link('checkpoints', '/admin/races/race_checkpoints')
    admin.tabs['Races'].add_link('prizes', '/admin/races/race_instances')
    admin.tabs['Races'].add_link('categories', '/admin/races/race_categories')
    admin.tabs['Races'].add_link('results', '/admin/races/race_instances')
  end
  
  def deactivate
    admin.tabs.remove "Races"
  end
  
end
