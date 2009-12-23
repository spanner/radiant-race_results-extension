require File.dirname(__FILE__) + '/../spec_helper'

describe RaceClub do
  dataset :races
  
  describe "on validation" do
    before do
      @club = race_clubs(:black_combe)
      @club.should be_valid
    end
    
    it "should require a name" do
      @club.name = nil
      @club.should_not be_valid
      @club.errors.on(:name).should_not be_empty
    end
  end
  
  describe "with aliases" do
    it "should be retrievable by name or alias" do
      RaceClub.find_by_name_or_alias('Black Combe').should == race_clubs(:black_combe)
      RaceClub.find_by_name_or_alias('BCR').should == race_clubs(:black_combe)
      RaceClub.find_by_name_or_alias('Black Combe Runners').should == race_clubs(:black_combe)
      RaceClub.find_by_name_or_alias('camel').should be_nil
    end

    it "should be find_or_creatable by name or alias" do
      RaceClub.find_or_create_by_name_or_alias('BCR').should == race_clubs(:black_combe)
      RaceClub.find_or_create_by_name_or_alias('CFR').should be_kind_of(RaceClub)
    end
  end
end
