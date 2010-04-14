class RacePerformancesController < ApplicationController
  radiant_layout { |controller| controller.layout_for :races }
  no_login_required
  before_filter :get_race, :only => :show

  def show
    @performance = @race.performances.find(params[:id])
  end

private

  def get_race
    @race = Race.find(params[:race_id])
  end

end
