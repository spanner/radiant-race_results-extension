require File.dirname(__FILE__) + '/../spec_helper'

describe RaceCategory do
  dataset :races
  
  describe "on validation" do
    before do
      @category = race_categories(:mv40)
      @category.should be_valid
    end
    
    it "should require a name" do
      @category.name = nil
      @category.should_not be_valid
      @category.errors.on(:name).should_not be_empty
    end
  end
  
  describe "#within(category)" do
    it "should return a list of all the categories whose members are eligible in this category" do
      RaceCategory.within(race_categories(:mv50)).should == [race_categories(:mv50), race_categories(:mv60)]
    end
  end

end
