class RaceInstancesController < SiteController
  radiant_layout { |controller| Radiant::Config['races.layout'] }
  no_login_required
  before_filter :get_race, :only => :show

  def show
    @instance = @race.instances.find_by_slug(params[:slug])
    @mode = params[:mode] == 'splits' ? 'splits' : 'ranking'
    @performances = @instance.performances
    if params[:club] && @club = RaceClub.find(params[:club])
      @performances = @performances.by_members_of(@club)
    end
    if params[:cat] && @category = @instance.categories.find_by_name(params[:cat])
      @performances = @performances.eligible_for_category(@category)
    end
    expires_in 1.month, :private => false, :public => true
  end


  # we need a downloadable splits file
  # mode flag to choose splits partials instead of ranking partials?
  

private

  def get_race
    @race = Race.find_by_slug(params[:race_slug])
  end

end
