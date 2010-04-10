class Admin::RaceCompetitorsController < Admin::ResourceController
  helper :races
  before_filter :get_competitor, :only => [:edit, :update, :delete]
  before_filter :make_competitor, :only => [:new, :create]

  def load_models
    self.models = model_class.paginate(pagination_options)
  end

protected

  def get_competitor
    @race_competitor = RaceCompetitor.find(params[:id])
  end

  def make_competitor
    @race_competitor = RaceCompetitor.new(params[:race_competitor])
  end
end
