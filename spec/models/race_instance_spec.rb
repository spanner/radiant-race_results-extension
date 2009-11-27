require File.dirname(__FILE__) + '/../spec_helper'
require 'csv'

describe RaceInstance do
  dataset :races
  
  describe "on validation" do
    before do
      @ri = races(:caw).in(2009)
      @ri.should be_valid
    end
    
    it "should require a slug" do
      @ri.slug = nil
      @ri.should_not be_valid
      @ri.errors.on(:slug).should_not be_empty
    end
    
    ["", "with a space", "/", "../../../hm", "2008"]. each do |badslug|
      it "should reject the unsuitable slug #{badslug}" do
        @ri.slug = badslug
        @ri.should_not be_valid
        @ri.errors.on(:slug).should_not be_empty
      end
    end
  end

  describe "A simple race" do
    before do
      @ri = races(:caw).in(2009)
    end
    
    it "should have race categories" do
      @ri.categories.any?.should be_true
      @ri.categories.include?(race_categories(:m)).should be_true
      @ri.categories.include?(race_categories(:mv40)).should be_true
      @ri.categories.include?(race_categories(:lv70)).should be_false
    end

    it "should have performances" do
      @ri.performances.any?.should be_true
    end

    it "should have competitors" do
      @ri.competitors.any?.should be_true
      @ri.competitors.count.should == 5
    end

    it "should have a winner" do
      @ri.winner.should == race_competitors(:ben_abdelnoor)
    end

    it "should have a category winner" do
      @ri.winner('MV40').should == race_competitors(:gary_thorpe)
    end
  end

  describe "Importing results" do
    before do
      @race = Race.create(:name => "Long Duddon", :slug => 'long_duddon')
      @ri = @race.instances.new({
        :name => '2008', 
        :slug => '2008'
      })
      @ri.should_receive(:read_results_file).and_return(CSV.read(File.dirname(__FILE__) + '/../files/long_duddon_2008.csv'))
      @ri.results_updated = true
      @ri.save!
    end
    
    it "should get performances" do
      @ri.performances.any?.should be_true
    end
    
    # it "should get competitors" do
    #   @ri.competitors.any?.should be_true
    # end
    # 
    # it "should get categories" do
    #   @ri.categories.any?.should be_true
    # end
    # 
    # it "should get checkpoints" do
    #   @ri.checkpoints.any?.should be_true
    # end
    
    
    
    
    
    
    
    
    
  end

end
