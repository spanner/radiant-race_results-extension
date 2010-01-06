class RacesController < ApplicationController
  radiant_layout "BCR Races"

  def show
    @race = Race.find_by_slug(params[:slug])
  end
  
  def index
    @races = Race.find(:all)
  end

end
