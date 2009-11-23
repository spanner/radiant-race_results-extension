require File.dirname(__FILE__) + '/../spec_helper'

describe Race do
  dataset :races
  
  describe "on validation" do
    before do
      @race = races(:caw)
      @race.should be_valid
    end
    
    it "should require a name" do
      @race.name = nil
      @race.should_not be_valid
      @race.errors.on(:name).should_not be_empty
    end
    
    ["", "with a space", "/", "../../../hm"]. each do |badslug|
      it "should reject the unsuitable slug #{badslug}" do
        @race.slug = badslug
        @race.should_not be_valid
        @race.errors.on(:slug).should_not be_empty
      end
    end
  end
  
  describe "#in(year)" do
    it "should find the right instance" do
      races(:caw).in('2008').should == race_instances(:'2008')
    end
  end
  
  describe "#latest" do
    it "should find the most recent instance" do
      races(:caw).latest.should == race_instances(:'2009')
    end
  end
  
end
