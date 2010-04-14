class RacesController < ApplicationController
  radiant_layout { |controller| controller.layout_for :races }
  no_login_required

  def show
    @race = Race.find_by_slug(params[:slug])
  end
  
  def index
    @races = Race.all.paginate(pagination_parameters)
  end

end
