class RaceResultsPage < Page

  description %{ Supports a series of race results pages. }

  def self.sphinx_indexes
    []
  end

  def cache?
    true
  end

  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    if (url =~ %r{^#{ self.url }}) && (not live or published?)
      self
    else
      super
    end
  end
  
  # we ought to be munching date parameters (eg from, since) into Date objects

  def race_category
    @request.path_parameters[:url][1]
  end
  
  def race_slug
    @request.path_parameters[:url][2]
  end

end
