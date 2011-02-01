class RacePerformancesController < SiteController
  radiant_layout { |controller| Radiant::Config['races.layout'] }
  no_login_required
  before_filter :get_race, :only => :show

  def show
    expires_in 1.month, :private => false, :public => true
    @performance = @race.performances.find(params[:id])
  end

private

  def get_race
    @race = Race.find(params[:race_id])
  end

end
