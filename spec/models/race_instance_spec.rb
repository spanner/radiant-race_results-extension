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

  describe "importing results from a file with checkpoints" do
    before do
      @race = races(:duddon)
      @cp = @race.checkpoints.find_by_name("Harter")
      @ri = @race.in(2010)
      @ri.stub!(:read_results_file).and_return(CSV.read(File.dirname(__FILE__) + '/../files/long_duddon_2008.csv'))
      @ri.send :process_results_file
      @perf = @ri.winning_performance
    end
    
    it "should import performances" do
      @ri.performances.any?.should be_true
      @ri.performances.count.should == 229
      @perf.competitor.should == RaceCompetitor.find_by_name("Simon Booth")
      @perf.elapsed_time.should == "2:52:31"
      @perf.position.should == 1
      @perf.status_id.should == 100
      @perf.status.should == RacePerformanceStatus['Finished']
    end

    it "should import checkpoint times" do
      @perf.checkpoint_times.any?.should be_true
      Rails.logger.warn ">>>"
      # p "checkpoint is #{@cp.inspect}"
      # p "checkpoint times are #{@perf.checkpoint_times.inspect}"
      # p "perf.time_at(@cp) is #{@perf.time_at(@cp).inspect}"
      # Rails.logger.warn "<<<"
      @perf.time_at(@cp).elapsed_time.should == "0:36:30"
    end
    
    it "should import categories and notice category winners" do
      @ri.categories.any?.should be_true
      @ri.categories.include?(race_categories(:mv40)).should be_true
      @ri.winner('MV40').should == RaceCompetitor.find_by_name("Simon Booth")
      @ri.winner('MV50').should == RaceCompetitor.find_by_name("David Spedding")
      @ri.winner('MV60').should == RaceCompetitor.find_by_name("David Spedding")
      # p "    L: #{RaceCategory.find_by_name('L').inspect}"
      # p "    LV40: #{RaceCategory.find_by_name('LV40').inspect}"
      # 
      # categories = RaceCategory.within("LV40")
      # p "    categories in LV40 and above: #{categories.map(&:name).to_sentence}"
      # 
      # exact = @ri.performances.in_category("LV40")
      # p "    performances in LV40: #{exact.inspect}"
      # 
      # eligible = @ri.performances.eligible_for_category("LV40")
      # p "    performances in LV40 and above: #{eligible.inspect}"
      @ri.winner('LV40').should == RaceCompetitor.find_by_name("Helene Whitaker")
      @ri.winner('L').should == RaceCompetitor.find_by_name("Janet McIver")
    end
  end

end
