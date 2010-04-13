class Admin::RaceClubsController < Admin::ResourceController
  helper :races
  before_filter :get_club, :only => [:edit, :update, :delete]
  before_filter :make_club, :only => [:new, :create]

protected

  def get_club
    @race_club = RaceClub.find(params[:id])
  end

  def make_club
    @race_club = RaceClub.new(params[:race_club])
  end
end