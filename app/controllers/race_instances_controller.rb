class RaceInstancesController < SiteController
  radiant_layout { |controller| Radiant::Config['races.layout'] }
  no_login_required
  before_filter :establish_context

  def show
    expires_in 1.month, :private => false, :public => true
    respond_to do |format|
      format.html {}
      format.csv {}
      format.json { render :json => @performances.completed }
    end
  end

  def splits
    expires_in 1.month, :private => false, :public => true
    @checkpoints = @instance.checkpoints
    @splits = @instance.assembled_checkpoint_times
  end

private

  def establish_context
    @race = Race.find_by_slug(params[:race_slug])
    @instance = @race.instances.find_by_slug(params[:slug])
    @performances = @instance.performances
    if params[:club] && @club = RaceClub.find(params[:club])
      @performances = @performances.by_members_of(@club)
    end
    if params[:cat] && @category = @instance.categories.find_by_name(params[:cat])
      @performances = @performances.eligible_for_category(@category)
    end
  end

end
