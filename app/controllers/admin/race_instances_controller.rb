class Admin::RaceInstancesController < Admin::ResourceController
  paginate_models
  
protected

  def continue_url(options)
    admin_races_url
  end

  def load_model
    @race = Race.find_by_slug(params[:race_id])
    self.model = if params[:id]
      @race.instances.find_by_slug(params[:id])
    else
      @race.instances.build
    end
  end
end