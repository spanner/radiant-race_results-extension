ActionController::Routing::Routes.draw do |map|
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

  map.race_instance '/races/:race_slug/:slug', :controller => 'race_instances', :action => 'show'
  map.race_club '/races/:race_slug/:slug/club/:club', :controller => 'race_instances', :action => 'show'
  map.race_category '/races/:race_slug/:slug/cat/:cat', :controller => 'race_instances', :action => 'show'

  map.race_performance '/races/:race_slug/:slug/p/:id', :controller => 'race_performances', :action => 'show'
  
  # map.resources :race_clubs
  # map.resources :race_competitors
end
