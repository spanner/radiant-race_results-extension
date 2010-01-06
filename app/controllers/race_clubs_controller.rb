class RaceClubsController < ApplicationController
  radiant_layout "BCR Races"
  before_filter :get_race, :only => :show

  def show
    @club = @instance.clubs.find_by_name(params[:slug])
    @performances = @instance.performances.by_members_of(@club)
  end

private

  def get_race
    @race = Race.find_by_slug(params[:race_slug])
    @instance = @race.instances.find_by_slug(params[:instance_slug])
  end

end
