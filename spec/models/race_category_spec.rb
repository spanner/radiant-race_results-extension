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

  describe "normalizing names" do
    it "should convert everything to M, L, MVxx, LVxx" do
      RaceCategory.normalized_name('M').should == "M"
      RaceCategory.normalized_name('L').should == "L"
      RaceCategory.normalized_name('F').should == "L"
      RaceCategory.normalized_name('W').should == "L"
      RaceCategory.normalized_name('M40').should == "MV40"
      RaceCategory.normalized_name('L50').should == "LV50"
      RaceCategory.normalized_name('F60').should == "LV60"
      RaceCategory.normalized_name('W70').should == "LV70"
      RaceCategory.normalized_name('FV45').should == "LV45"
      RaceCategory.normalized_name('WV70').should == "LV70"
    end
  end

  describe "finding or creating by name" do
    before do
      @cat = RaceCategory.find_or_create_by_normalized_name("FV45")
      @ucat = RaceCategory.find_or_create_by_normalized_name("LU21")
    end

    it "should normalize name" do
      @cat.name.should == "LV45"
    end

    it "should notice gender" do
      @cat.gender.should == "F"
    end

    it "should notice age threshold" do
      @cat.age_above.should == 45
    end
    
    it "should work for upper age limits too" do
      @ucat.age_below.should == 21
      @ucat.gender.should == "F"
    end
    
  end

end
