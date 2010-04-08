class RacePage < Page
  include WillPaginate::ViewHelpers

  description %{ Takes race and race instance names in child position or as parameters and populates the necessary race objects. }
  
  attr_accessor :race, :race_instance
  
  def self.sphinx_indexes
    []
  end
  
  def cache?
    true
  end
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    my_url = self.url
    return false unless url =~ /^#{Regexp.quote(my_url)}(.*)/
    race_slug, instance_slug, subset, id = $1.split('/')
    if race_slug && @race = Race.find_by_slug(race_slug)
      if instance_slug && @race_instance = @race.instances.find_by_slug(instance_slug)
        if subset && id && %w{club cat p}.include?(subset)
          case subset
          when "club"
            @club = RaceClub.find(id)
            @template = 'race_clubs/show'
          when "cat"
            @category = RaceCategory.find(id)
            @template = 'race_categories/show'
          when 'p'
            @performance = RacePerformance.find(id)
            @template = 'race_performances/show'
          end 
        else
          @template = 'race_instances/show'
        end
      else
        @template = 'races/show'
      end
    end
    self
  end

  def pagination
    p = request.params[:page]
    p = 1 if p.blank? || p == 0
    return {
      :page => request.params[:page] || 1, 
      :per_page => Radiant::Config['race_results.per_page'] || 100
    }
  end
  
  def render
    
  end
    
  def title
    if race_instance
      race_instance.full_name
    elsif race
      race.name
    else
      read_attribute(:title)
    end
  end
  
  
end
