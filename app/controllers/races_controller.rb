class RacesController < ApplicationController
  radiant_layout { |controller| controller.layout_for :races }

  def show
    @race = Race.find_by_slug(params[:slug])
  end
  
  def index
    @races = Race.all
  end

end
