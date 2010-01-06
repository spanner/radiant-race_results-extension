class RaceCategoriesController < ApplicationController
  radiant_layout "BCR Races"
  before_filter :get_race, :only => :show

  def show
    @category = @instance.categories.find_by_name(params[:slug])
    @performances = @instance.performances.eligible_for_category(@category)
  end

private

  def get_race
    @race = Race.find_by_slug(params[:race_slug])
    @instance = @race.instances.find_by_slug(params[:instance_slug])
  end

end
