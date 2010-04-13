class Admin::RacesController < Admin::ResourceController
  helper :races

protected

  def load_model
    self.model = if params[:id]
      model_class.find_by_slug(params[:id])
    else
      model_class.new
    end
  end
end