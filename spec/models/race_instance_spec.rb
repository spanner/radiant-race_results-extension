require File.dirname(__FILE__) + '/../spec_helper'

describe RaceInstance do
  dataset :races
  
  describe "on validation" do
    before do
      @ri = races(:caw).in(2009)
      @ri.should be_valid
    end
    
    it "should require a name" do
      @ri.name = nil
      @ri.should_not be_valid
      @ri.errors.on(:name).should_not be_empty
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
    end

    it "should have a winner" do
      @ri.winner.should == race_competitors(:ben_abdelnoor)
    end

    it "should have a category winner" do
      @ri.category_winner('MV40').should == race_competitors(:gary_thorpe)
    end

  end

    
end
