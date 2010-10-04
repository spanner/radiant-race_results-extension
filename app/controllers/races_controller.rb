class RacesController < ApplicationController
  include Radiant::Pagination::Controller
  radiant_layout { |controller| controller.choose_layout }
  no_login_required

  def show
    @race = Race.find_by_slug(params[:slug])
  end
  
  def index
    @races = Race.paginate(pagination_parameters)
  end
  
  def choose_layout
    if action_name == "show"
      layout = Radiant::Config['races.show_layout'] || Radiant::Config['races.layout']
    else
      layout = Radiant::Config['races.index_layout'] || Radiant::Config['races.layout']
    end
  end

end
