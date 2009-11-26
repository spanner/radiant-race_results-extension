class Admin::RaceInstancesController < Admin::ResourceController
  before_filter :get_race
  before_filter :get_race_instance, :only => [:edit, :update, :delete]
  before_filter :make_race_instance, :only => [:new]
  
protected

  def get_race
    @race = Race.find(params[:race_id])
  end
  
  def get_race_instance
    @race_instance = @race.instances.find(params[:id])
  end

  def make_race_instance
    @race_instance = @race.instances.build(params[:race])
  end
  
end