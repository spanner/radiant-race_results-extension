class RaceInstancesController < ApplicationController
  radiant_layout { |controller| Radiant::Config['races.results_layout'] || Radiant::Config['races.layout'] }
  no_login_required
  before_filter :get_race, :only => :show

  def show
    @instance = @race.instances.find_by_slug(params[:slug])
    @performances = @instance.performances
    if params[:club] && @club = RaceClub.find(params[:club])
      @performances = @performances.by_members_of(@club)
    end
    if params[:cat] && @category = @instance.categories.find_by_name(params[:cat])
      @performances = @performances.eligible_for_category(@category)
    end
  end

private

  def get_race
    @race = Race.find_by_slug(params[:race_slug])
  end

end
