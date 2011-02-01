class RacesController < SiteController
  include Radiant::Pagination::Controller
  radiant_layout { |controller| Radiant::Config['races.layout'] }
  no_login_required

  def show
    @race = Race.find_by_slug(params[:slug])
    expires_in 1.month, :private => false, :public => true
  end
  
  def index
    @races = Race.paginate(pagination_parameters)
    expires_in 1.month, :private => false, :public => true
  end

end
