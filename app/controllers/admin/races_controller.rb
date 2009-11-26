class Admin::RacesController < Admin::ResourceController
  before_filter :get_race, :only => [:edit, :update, :delete]
  before_filter :make_race, :only => [:new, :create]

protected

  def get_race
    @race = Race.find(params[:id])
  end

  def make_race
    @race = Race.new(params[:race])
  end
end