module RaceResults
  module Tags
    include Radiant::Taggable
    # include ActionView::Helpers::TextHelper
    # include ActionView::Helpers::TagHelper

    class TagError < StandardError; end

    ####### race list

    desc %{
      Loops through the list of races we know about. Takes the usual by and order parameters.
  
      *Usage:* 
      <pre><code><r:races:each>...</r:races:each></code></pre>
    }
    tag 'races' do |tag|
      _get_races(tag)
      tag.expand
    end
    tag 'races:each' do |tag|
      result = []
      tag.locals.races.each do |race|
        tag.locals.race = race
        result << tag.expand
      end
      result
    end

    ####### races

    desc %{
      Retreives a single race from the name or id you supply.
      All the r:race:* tags will follow the same retrieval rules.
  
      *Usage:* 
      <pre><code><r:race [name="dunnerdale"] [id="1"]>...</r:race></code></pre>
    }
    tag 'race' do |tag|
      _get_race(tag)
      tag.expand if tag.locals.race
    end

    [:id, :name, :slug].each do |field|
      desc %{
        Displays the #{field} column of the currently selected race.

        *Usage:* 
        <pre><code><r:race:#{field} /></code></pre>
      }
      tag "race:#{field}" do |tag|
        _get_race(tag)
        tag.locals.race.send(field) if tag.locals.race
      end
    end

    desc %{
      Loops through the list of instances of the present race, retrieving the set of results
      for each and making them available to any contained r:results tags.
  
      *Usage:* 
      <pre><code><r:race:instances:each>...</r:race:instances:each></code></pre>
    }
    tag 'race:instances' do |tag|
      _get_race(tag)
      raise TagError, "No race to show instances of" unless tag.locals.race
      tag.expand
    end
    tag 'race:instances:each' do |tag|
      result = []
      tag.locals.race.instances.each do |instance|
        tag.locals.race_instance = instance
        result << tag.expand
      end
      result
    end

    ####### race instances (required for most other tags)

    desc %{
      Retrieves a set of results from the specified race and instance.
  
      *Usage:* 
      <pre><code>
        <r:results race="dunnerdale" instance="2009">
          <ol>
            <r:performances:each>
              <li><r:performance:name />: <r:performance:elapsed_time /></li>
            </r:performances:each>
          </ol>
        </r:results>
      </code></pre>
    }
    tag 'results' do |tag|
      _get_race_instance(tag)
      raise TagError, "No race instance to show results of" unless tag.locals.race_instance
      tag.expand
    end

    [:checkpoints, :categories, :competitors, :performances].each do |collection|
      desc %{
        Loops through the list of #{collection} in the current results set.
  
        *Usage:* 
        <pre><code><r:#{collection}:each [limit="10"]>...</r:#{collection}:each></code></pre>
      }
      tag "#{collection}" do |tag|
        _get_race_instance(tag)
        raise TagError, "No race instance in which to show #{collection}" unless tag.locals.race_instance
        tag.expand
      end
      tag "#{collection}:each" do |tag|
        _get_race_instance(tag)
        result = []
        tag.locals.race_instance.send(colletion).each do |member|
          tag.locals.send("#{collection.to_s.singularize}=".intern, member)
          result << tag.expand
        end
        result
      end
    end

    ####### performances

    desc %{
      Retrieves a single performance from the result set, based on the race number or position that you supply.
  
      *Usage:* 
      <pre><code><r:performance [number="1"] [position="1"]>...</r:performance></code></pre>
    }
    tag 'performance' do |tag|
      raise TagError, "No race instance available within which to find a performance" unless tag.locals.race_instance
      _get_race_performance(tag)
      raise TagError, "No race performance found" unless tag.locals.performance
      tag.expand
    end

    [:name, :number, :elapsed_time, :position].each do |field|
      desc %{
        Displays the #{field} column of the performance currently in the foreground.

        *Usage:* 
        <pre><code><r:performance:#{field} /></code></pre>
      }
      tag "performance:#{field}" do |tag|
        _get_race_performance(tag)
        tag.locals.performance.send(field) if tag.locals.performance
      end
    end

    [:club, :category, :competitor, :race_instance].each do |association|
      desc %{
        Retrieves the #{association} associated with the performance currently in the foreground 

        If double, we expand and make the #{association} available to any contained r:#{association} tags.

        If single, we just display the name of the #{association}.

        <pre><code>
          <r:performance:#{association} />
          <r:performance:#{association}>...</r:performance:#{association}></code></pre>
        </code></pre>
      }
      tag "performance:#{association}" do |tag|
        _get_race_performance(tag)
        if tag.double?
          tag.locals.send("#{association}=".intern, tag.locals.performance.send(association))
          tag.expand
        else
          associate = tag.locals.performance.send(association)
          associate.name if associate
        end
      end
    end
  
    desc %{
      Loops through the list of checkpoint times associated with the present performance. Within this tag
      you can use r:checkpoint_time singly just to show the split time, or a clause like this to show more detail:
    
      *Usage:* 
      <pre><code>
        <r:performance:checkpoint_times:each>
          <strong><r:checkpoint_time:elapsed_time /><strong><br />
          pos: <r:checkpoint_time:position /> (<r:checkpoint_time:gain />)
        </r:performance:checkpoint_times:each>
      </code></pre>
    }
    tag 'performance:checkpoint_times' do |tag|
      _get_race_performance(tag)
      raise TagError, "No performance to find times for" unless tag.locals.performance
      tag.expand
    end
    tag 'performance:checkpoint_times:each' do |tag|
      _get_race_performance(tag)
      result = []
      tag.locals.performance.checkpoint_times.each do |time|
        tag.locals.checkpoint_time = time
        result << tag.expand
      end
      result
    end
  

    ####### categories

    desc %{
      Retrieves a single category from the result set, based on the name that you supply.
  
      *Usage:* 
      <pre><code><r:category name="MV40">...</r:category></code></pre>
    }
    tag 'category' do |tag|
      _get_race_category(tag)
      raise TagError, "No race category found" unless tag.locals.category
      tag.expand
    end

    [:name, :record, :entries, :finishers].each do |field|
      desc %{
        Displays the #{field} column of the race category currently in the foreground.

        *Usage:* 
        <pre><code><r:category:#{field} /></code></pre>
      }
      tag "category:#{field}" do |tag|
        _get_race_category(tag)
        tag.locals.category.send(field) if tag.locals.category
      end
    end

    desc %{
      Loops through the list of performances in the present racea category, making them available
      to the usual r:performance tags.
    
      Supply a @limit@ attribute to limit the size of the list returned.
  
      *Usage:* 
      <pre><code><r:category:performances:each [limit="10"]>...</r:category:performances:each></code></pre>
    }
    tag 'category:performances' do |tag|
      _get_race_category(tag)
      raise TagError, "No category to draw performances from" unless tag.locals.category
      tag.expand
    end
    tag 'category:performances:each' do |tag|
      _get_race_category(tag)
      result = []
      tag.locals.category.performances.each do |performance|
        tag.locals.performance = performance
        result << tag.expand
      end
      result
    end

    ####### clubs

    desc %{
      Retrieves a single club from the result set, based on the name that you supply.
  
      *Usage:* 
      <pre><code><r:club name="Black Combe Runners">...</r:club></code></pre>
    }
    tag 'club' do |tag|
      _get_club(tag)
      raise TagError, "No club found" unless tag.locals.club
      tag.expand
    end
    [:name, :url].each do |field|
      desc %{
        Displays the #{field} column of the club currently in the foreground.

        *Usage:* 
        <pre><code><r:club:#{field} /></code></pre>
      }
      tag "club:#{field}" do |tag|
        _get_club(tag)
        tag.locals.club ||= _get_race_club(tag)
        tag.locals.club.send(field) if tag.locals.club
      end
    end

    desc %{
      Renders a link to the club currently in the foreground. Attributes and link text are passed through as usual.

      *Usage:* 
      <pre><code><r:club:link class="cssclass" /></code></pre>
    }
    tag "club:link" do |tag|
      _get_club(tag)
      raise TagError, "No club to link to" unless tag.locals.club
      options = tag.attr.dup
      anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
      attributes = options.inject(' ') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
      text = tag.double? ? tag.expand : tag.render('club:name')
      %{<a href="#{tag.render('club:url')}#{anchor}"#{attributes}>#{text}</a>}
    end

    ####### checkpoints

    desc %{
      Retrieves a single checkpoint from the result set, based on the name that you supply.
    
      *Usage:* 
      <pre><code><r:checkpoint name="Raven Crag">...</r:checkpoint></code></pre>
    }
    tag 'checkpoint' do |tag|
      _get_race_checkpoint(tag)
      raise TagError, "No checkpoint found" unless tag.locals.checkpoint
      tag.expand
    end
    [:name, :location].each do |field|
      desc %{
        Displays the #{field} column of the checkpoint currently in the foreground.

        *Usage:* 
        <pre><code><r:checkpoint:#{field} /></code></pre>
      }
      tag "checkpoint:#{field}" do |tag|
        _get_race_checkpoint(tag)
        tag.locals.checkpoint.send(field) if tag.locals.club
      end
    end

    desc %{
      Loops through the list of checkpoint times associated with the present checkpoint.
    
      Supply a @limit@ attribute to limit the size of the list returned.
    
      *Usage:* 
      <pre><code><r:checkpoint:times:each [limit="10"]>...</r:checkpoint:times:each></code></pre>
    }
    tag 'checkpoint:times' do |tag|
      _get_race_checkpoint(tag)
      raise TagError, "No checkpoint to find times for" unless tag.locals.checkpoint
      tag.expand
    end
    tag 'checkpoint:times:each' do |tag|
      _get_race_checkpoint(tag)
      result = []
      tag.locals.checkpoint.times.each do |time|
        tag.locals.checkpoint_time = time
        result << tag.expand
      end
      result
    end
  
    ####### checkpoint times are only shown in lists

    desc %{
      Retrieves a single checkpoint from the result set, based on the name that you supply.

      Used singly: it just displays the time at that checkpoint.
    
      If double, it expands in the usual way. You can use r:performance:* tags within this tag if you want to display
      a list of arrivals at this point, and r:checkpoint_time:* tags to display the time, position and gain data. 
      This is only likely to happen when you're displaying an individual performance but it is also possible to build
      a complete splits table this way.
      
    }
    tag 'checkpoint_time' do |tag|
      raise TagError, "checkpoint_time tag can only be used in a results list" unless tag.locals.checkpoint_time
      if tag.double?
        tag.locals.performance = tag.locals.checkpoint_time.performance
        tag.expand
      else
        tag.locals.checkpoint_time.elapsed_time
      end
    end

    [:elapsed_time, :position, :gain].each do |field|
      desc %{
        Displays the #{field} of the checkpoint arrival time currently in the foreground.

        *Usage:* 
        <pre><code><r:checkpoint_time:#{field} /></code></pre>
      }
      tag "checkpoint_time:#{field}" do |tag|
        raise TagError, "checkpoint_time:* tags can only be used in a results list" unless tag.locals.checkpoint_time
        tag.locals.checkpoint_time.send(field)
      end
    end

    ####### standard display blocks

    desc %{
      Displays a complete table of race results in a simple standard format.
    }
    tag 'results:table' do |tag|
      _get_race_instance
      raise TagError, "No race instance to list" unless tag.locals.race_instance
      result = []
      result << %{<table class="results">}
      result << tag.render('results:header')
      tag.locals.performances = tag.locals.race_instance.performances
      result << tag.render('performances:table')
      result << %{</table>}
      result.flatten
    end

    desc %{
      Displays a standard list of performances. This is here to support the results:table and category:table but you can 
      use it directly if you like. A list of perfomances must be available.
    }
    tag 'performances:table' do |tag|
      raise TagError, "No performances to display" unless tag.locals.performances
      result = []
      result << %{<tbody>}
      if tag.locals.performances.any?
        tag.locals.performances.each do |performance|
          tag.locals.performance = performance
          result << %{
    <tr>
      <td>#{tag.render('performance:position')}</td>
      <td>#{tag.render('performance:name')}</td>
      <td>#{tag.render('performance:club')}</td>
      <td>#{tag.render('performance:category')}</td>
      <td>#{tag.render('performance:time')}</td>
    </tr>
          }
        end
      else
        result << %{<tr><td colspan="5" class="nodata">No results to display</td></tr>}
      end
      result << %{</tbody>}
      result
    end

    desc %{
      Displays standard column headings suitable for use in any of the results tables
    }
    tag 'results:header' do |tag|
      %{<thead><tr><th>Pos</th><th>Name</th><th>Club</th><th>Cat</th><th>Time</th></tr></thead>}
    end

    desc %{
      Displays a complete table of splits for the current race.
    }
    tag 'results:splits' do |tag|
    
    end

    desc %{
      Displays a complete table of results in the current category, in a simple standard format.
    }
    tag 'category:list' do |tag|
    
    end

    desc %{
      Displays a table of the prize-winning performances suitable for use on a summary page.
    }
    tag 'results:prizes' do |tag|
    
    end

    desc %{
      Displays a table of the category-prize-winning performances suitable for use on a summary page.
    }
    tag 'category:prizes' do |tag|

    end

    ####### page furniture


    desc %{
      Renders a trail of breadcrumbs to the current page. On a race_results page this tag is 
      overridden to show the name and instance of the race being displayed

      *Usage:*

      <pre><code><r:breadcrumbs [separator="separator_string"] [nolinks="true"] /></code></pre>
    }
    tag 'breadcrumbs' do |tag|
      page = tag.locals.page
      nolinks = (tag.attr['nolinks'] == 'true')
    
      if race
        crumbs = nolinks ? [page.breadcrumb] : [%{<a href="#{url}">#{tag.render('breadcrumb')}</a>}]
        if race_instance
          crumbs << (nolinks ? race : %{<a href="#{url}/#{race.slug}">#{race.name}</a>})
          crumbs << race_instance.name
        else
          crumbs << race.name
        end
      else
       crumbs = [page.breadcrumb]
      end
      page.ancestors.each do |ancestor|
        tag.locals.page = ancestor
        if nolinks
          crumbs.unshift tag.render('breadcrumb')
        else
          crumbs.unshift %{<a href="#{tag.render('url')}">#{tag.render('breadcrumb')}</a>}
        end
      end
      separator = tag.attr['separator'] || ' &gt; '
      crumbs.join(separator)
    end








  private

    def _get_race(tag)
      return tag.locals.races if tag.locals.races
      tag.locals.races = Race.all
    end

    def _get_race(tag)
      return tag.locals.race if tag.locals.race
      raise TagError, "no race name supplied" unless tag.attr['name']
      tag.locals.race = Race.find_by_name(tag.attr['name'])
    end

    def _get_race_instance(tag)
      return tag.locals.race_instance if tag.locals.race_instance
      _get_race(tag)
      raise TagError, "no race found" unless tag.locals.race
      tag.locals.race_instance = tag.locals.race.in(tag.attr['instance'])
    end

    def _get_race_category(tag)
      return tag.locals.category if tag.locals.category
      raise TagError, "No race instance available within which to find a category" unless tag.locals.race_instance
      raise TagError, "No category name supplied" unless tag.attr['name']
      tag.locals.category = tag.locals.race_instance.categories.find_by_name(tag.attr['name'])
    end

    def _get_race_performance(tag)
      return tag.locals.performance if tag.locals.performance
      raise TagError, "No race instance available within which to find a peformance" unless tag.locals.race_instance
      if name = tag.attr['name']
        tag.locals.performance = tag.locals.race_instance.performance_by(tag.locals.race_instance.competitors.find_by_name(name))
      elsif position = tag.attr['position']
        tag.locals.performance = tag.locals.race_instance.performance_at(position)
      elsif number = tag.attr['number']
        tag.locals.performance = tag.locals.race_instance.performance.find_by_number(number)
      else
        raise TagError, "Performance name, number or position is required"
      end
    end

    def _get_race_checkpoint(tag)
      return tag.locals.checkpoint if tag.locals.checkpoint
      raise TagError, "No race instance available within which to find a checkpoint" unless tag.locals.race_instance
      raise TagError, "No checkpoint name supplied" unless tag.attr['name']
      tag.locals.checkpoint = tag.locals.race_instance.checkpoints.find_by_name(tag.attr['name'])
    end

    def _get_club(tag)
      return tag.locals.club if tag.locals.club
      raise TagError, "No club name supplied" unless tag.attr['name']
      tag.locals.club = RaceClub.find_by_name(tag.attr['name'])
    end

  end
end