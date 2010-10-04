class Admin::RacesController < Admin::ResourceController
  paginate_models
  helper :races
  paginate_models

  def update
    model.update_attributes!(params[model_symbol])
    response_for :update
  end

  def continue_url(options)
    options[:redirect_to] || (params[:continue] ? {:action => 'edit', :id => model.slug} : {:action => "index"})
  end

  def load_model
    Rails.logger.warn "loading model with id #{params[:id].inspect}"
    
    self.model = if params[:id]
      model_class.find(params[:id])
    else
      model_class.new
    end
  end

protected

  def load_model
    self.model = if params[:id]
      model_class.find_by_slug(params[:id])
    else
      model_class.new
    end
  end
  
  
end