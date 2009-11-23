class RacesDataset < Dataset::Base
  datasets = [:users]
  datasets << :race_sites if defined? Site
  uses *datasets

  def load
    create_club "Ambleside" do
      create_competitor "Ben Abdelnoor"
      create_competitor "Gary Thorpe"
    end
    create_club "Dark Peak" do
      create_competitor "Mike Robinson"
    end
    create_club "Helm Hill" do
      create_competitor "Chris Robinson"
      create_competitor "Tom Doyle"
    end
    create_club "Black Combe" do
      create_competitor "Pete Tayler"
      create_competitor "William Ross"
    end

    create_category 'M', :age_above => 0, :age_below => nil, :gender => 'M'
    create_category 'MV40', :age_above => 40, :age_below => nil, :gender => 'M'
    create_category 'MV50', :age_above => 50, :age_below => nil, :gender => 'M'
    create_category 'MV60', :age_above => 60, :age_below => nil, :gender => 'M'
    create_category 'LV70', :age_above => 70, :age_below => nil, :gender => 'F'
    create_category 'U21', :age_above => nil, :age_below => 21, :gender => nil

    create_race "Caw" do
      create_instance "2008", :started_at => DateTime.civil(2008, 5, 7, 19, 30, 0)
      create_instance "2009", :started_at => DateTime.civil(2009, 5, 6, 19, 30, 0) do
        include_category 'M', :prizes => 3, :team_prizes => 1
        include_category 'MV40', :prizes => 3, :team_prizes => 1
        create_performance :race_competitor_id => race_competitor_id(:ben_abdelnoor), :elapsed_time => '50:40', :race_category_id => race_category_id(:m)
        create_performance :race_competitor_id => race_competitor_id(:mike_robinson), :elapsed_time => '52:50', :race_category_id => race_category_id(:m)
        create_performance :race_competitor_id => race_competitor_id(:chris_robinson), :elapsed_time => '53:34', :race_category_id => race_category_id(:m)
        create_performance :race_competitor_id => race_competitor_id(:tom_doyle), :elapsed_time => '54:34', :race_category_id => race_category_id(:m)
        create_performance :race_competitor_id => race_competitor_id(:gary_thorpe), :elapsed_time => '55:45', :race_category_id => race_category_id(:mv40)
      end
    end
    create_race "Dunnerdale" do
      create_instance "2007", :started_at => DateTime.civil(2009, 11, 14, 12, 0, 0) do
        include_category 'M', :prizes => 3, :team_prizes => 1
        include_category 'MV40', :prizes => 3, :team_prizes => 1
        create_checkpoint "Knott"
        create_checkpoint "Raven Crag"
        create_checkpoint "Stickle Pike"
        create_checkpoint "Great Stickle"
        create_performance :race_competitor_id => race_competitor_id(:ben_abdelnoor), :race_category_id => race_category_id(:m), :elapsed_time => '41:41' do
          create_checkpoint_time "9:12", :race_checkpoint_id => race_checkpoint_id(:knott)
          create_checkpoint_time "18:12", :race_checkpoint_id => race_checkpoint_id(:raven_crag)
          create_checkpoint_time "27:12", :race_checkpoint_id => race_checkpoint_id(:stickle_pike)
          create_checkpoint_time "35:12", :race_checkpoint_id => race_checkpoint_id(:great_stickle)
        end
        create_performance :race_competitor_id => race_competitor_id(:pete_tayler), :race_category_id => race_category_id(:mv40), :elapsed_time => '47:54' do
          create_checkpoint_time "12:12", :race_checkpoint_id => race_checkpoint_id(:knott)
          create_checkpoint_time "17:12", :race_checkpoint_id => race_checkpoint_id(:raven_crag)
          create_checkpoint_time "29:12", :race_checkpoint_id => race_checkpoint_id(:stickle_pike)
          create_checkpoint_time "39:12", :race_checkpoint_id => race_checkpoint_id(:great_stickle)
        end
        create_performance :race_competitor_id => race_competitor_id(:william_ross), :race_category_id => race_category_id(:m), :elapsed_time => '53:11' do
          create_checkpoint_time "13:12", :race_checkpoint_id => race_checkpoint_id(:knott)
          create_checkpoint_time "24:12", :race_checkpoint_id => race_checkpoint_id(:raven_crag)
          create_checkpoint_time "36:12", :race_checkpoint_id => race_checkpoint_id(:stickle_pike)
          create_checkpoint_time "47:12", :race_checkpoint_id => race_checkpoint_id(:great_stickle)
        end
      end
    end
    create_race "Scored" do
      create_instance "2010", :started_at => DateTime.civil(2008, 10, 6, 9, 0, 0) do
        create_checkpoint "Big", :value => 50
        create_checkpoint "Small", :value => 10
        create_checkpoint "Middling", :value => 25
      end
    end
  end
  
  helpers do
    def create_club(name, attributes={})
      symbol = name.symbolize
      attributes[:name] = name
      club = create_model :race_club, symbol, attributes
      club.update_attribute(:created_by, users(:existing))    # the post-hook will have nulled it after creation
      if block_given?
        @race_club_id = club.id
        yield
      end
    end

    def create_competitor(name, attributes={})
      symbol = name.symbolize
      attributes[:name] = name
      attributes[:race_club_id] ||= @race_club_id
      competitor = create_model :race_competitor, symbol, attributes
    end

    def create_race(name, attributes={})
      symbol = name.symbolize
      attributes[:name] = name
      attributes[:slug] ||= symbol.to_s
      attributes[:site] ||= sites(:test) if defined? Site
      race = create_model :race, symbol, attributes
      race.update_attribute(:created_by, users(:existing))    # the post-hook will have nulled it after creation
      if block_given?
        @race_id = race.id
        yield
      end
    end
    
    def create_instance(name, attributes={})
      symbol = name.symbolize
      attributes = {
        :name => name,
        :slug => symbol.to_s,
        :started_at => Time.now - 1.year,
        :race_id => @race_id
      }.update(attributes)
      attributes[:site_id] = site_id(:test) if defined? Site
      ri = create_model :race_instance, symbol, attributes
      ri.update_attribute(:created_by, users(:existing))    # the post-hook will have nulled it after creation
      if block_given?
        @race_instance_id = ri.id
        yield
      end
    end

    def create_category(name, attributes={})
      symbol = name.symbolize
      attributes[:name] ||= name
      category = create_model :race_category, symbol, attributes
    end
    
    def include_category(name, attributes={})
      symbol = make_unique_id(:race_instance_category)
      attributes[:race_instance_id] ||= @race_instance_id
      attributes[:site_id] = site_id(:test) if defined? Site
      attributes[:race_category_id] = race_category_id(name.symbolize)
      create_record :race_instance_category, symbol, attributes
    end
    
    def create_checkpoint(name, attributes={})
      symbol = name.symbolize
      attributes = {
        :name => name,
        :description => "Checkpoint description",
        :location => "SD555555",
        :race_instance_id => @race_instance_id
      }.update(attributes)
      attributes[:site_id] = site_id(:test) if defined? Site
      create_record :race_checkpoint, symbol, attributes
    end
    
    def create_performance(attributes={})
      symbol = make_unique_id(:race_performance)
      attributes[:race_instance_id] ||= @race_instance_id
      attributes[:site_id] = site_id(:test) if defined? Site
      performance = create_model :race_performance, symbol, attributes
      if block_given?
        @race_performance_id = performance.id
        yield
      end
    end
    
    def create_checkpoint_time(time, attributes={})
      symbol = make_unique_id(:checkpoint_time)
      attributes[:elapsed_time] = time
      attributes[:race_performance_id] ||= @race_performance_id
      attributes[:site_id] = site_id(:test) if defined? Site
      create_record :race_checkpoint_time, symbol, attributes
    end
    
  private
    @@call_count = 0
    def make_unique_id(klass)
      @@call_count += 1
      "#{klass.to_s} #{@@call_count}"
    end
  
  end
end