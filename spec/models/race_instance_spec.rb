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






    
end
