class RacePage < Page
  include WillPaginate::ViewHelpers

  class RedirectRequired < StandardError
    def initialize(message = nil); super end
  end

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
    parts = $1.split('/')
    if race_slug = parts.shift
      @race = Race.find_by_slug(race_slug)
      if instance_slug = parts.shift
        @race_instance = @race.instances.find_by_slug(instance_slug)
      else
        @race_instance = @race.latest
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
  
  def race
    @race
  end
  
  def race_instance
    @race_instance
  end
  
  def title
    if @race_instance
      @race_instance.full_name
    elsif @race
      @race.name
    else
      read_attribute(:title)
    end
  end
  
  
end
