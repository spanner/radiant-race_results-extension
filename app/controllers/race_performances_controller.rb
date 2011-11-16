class RacePerformancesController < SiteController
  radiant_layout { |controller| Radiant::Config['races.layout'] }
  no_login_required
  before_filter :establish_context, :only => :show

  def show
    respond_to do |format|
      format.html { 
        expires_in 1.month, :private => false, :public => true
        render
      }
      format.json {
        render :json => @performance.neighbours(10).to_json(:vs => @performance)
      }
    end
  end

private

  def establish_context
    @race = Race.find_by_slug(params[:race_slug])
    @instance = @race.instances.find_by_slug(params[:slug])
    @performance = @instance.performances.find(params[:id])
  end

end
