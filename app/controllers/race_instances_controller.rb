class RaceInstancesController < ApplicationController
  radiant_layout "BCR Races"
  before_filter :get_race, :only => :show

  def show
    @instance = @race.instances.find_by_slug(params[:slug])
  end

private

  def get_race
    @race = Race.find_by_slug(params[:race_slug])
  end

end
