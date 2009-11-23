class CompetitorsDataset < Dataset::Base
  datasets = [:races]
  datasets << :race_sites if defined? Site
  uses *datasets

  def load
    create_race "Caw" do
      create_instance "2007", :started_at => DateTime.civil(2007, 5, 7, 19, 30, 0)
      create_instance "2008", :started_at => DateTime.civil(2008, 5, 6, 19, 30, 0)
    end
    create_race "Dunnerdale" do
      create_instance "2009", :started_at => DateTime.civil(2009, 11, 14, 12, 0, 0) do
        create_checkpoint "Knott"
        create_checkpoint "Raven Crag"
        create_checkpoint "Stickle Pike"
        create_checkpoint "Great Stickle"
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
    def create_race(name, attributes={})
      attributes = race_attributes(attributes.update(:name => name))
      symbol = name.symbolize
      race = create_model :race, symbol, attributes
      race.update_attribute(:created_by, users(:existing))    # the post-hook will have nulled it after creation
      if block_given?
        @race_id = race_id(symbol)
        yield
      end
    end
    def race_attributes(attributes={})
      attributes[:name] ||= "race"
      attributes[:slug] ||= attributes[:name].symbolize.to_s
      attributes[:site] ||= sites(:test) if defined? Site
      attributes
    end
    
    def create_instance(name, attributes={})
      attributes = race_instance_params(attributes.update(:name => name))
      symbol = name.symbolize
      create_record :race_instance, symbol, attributes
      if block_given?
        @race_instance_id = race_instance_id(symbol)
        yield
      end
    end
    def race_instance_params(attributes={})
      attributes.reverse_merge({
        :name => 'Example',
        :start_time => Time.now - 1.year
      })
      attributes[:race_id] = @race_id
      attributes[:slug] ||= attributes[:name].symbolize.to_s
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end
    
    def create_checkpoint(name, attributes={})
      attributes = checkpoint_params(attributes.reverse_merge(:name => name))
      create_record :race_checkpoint, name.symbolize, attributes
    end
    def checkpoint_params(attributes={})
      attributes.reverse_merge({
        :name => "innominate",
        :description => "Checkpoint description",
        :location => "SD555555"
      })
      attributes[:race_instance_id] = @race_instance_id
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end
  end
end