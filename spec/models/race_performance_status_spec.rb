require File.dirname(__FILE__) + '/../spec_helper'

describe RacePerformanceStatus do

  describe "instantiating from an id" do
    it "should return the right status" do
      RacePerformanceStatus.find(100).should == RacePerformanceStatus[:finished]
    end
  end
  
  describe "instantiating from a value" do
    it "should return the right status" do
      RacePerformanceStatus['Finished'].id.should == 100
      RacePerformanceStatus['DNF'].id.should == 20
      RacePerformanceStatus['Unknown'].id.should == 0
    end
  end
  
  describe "instantiating from a time" do
    it "should return the right status" do
      RacePerformanceStatus.from_time(100).should == RacePerformanceStatus[:finished]
      RacePerformanceStatus.from_time(100.1).should == RacePerformanceStatus[:finished]
      RacePerformanceStatus.from_time("100").should == RacePerformanceStatus[:finished]
      RacePerformanceStatus.from_time("100.1").should == RacePerformanceStatus[:finished]
      RacePerformanceStatus.from_time("1:23:45").should == RacePerformanceStatus[:finished]
      RacePerformanceStatus.from_time("dnf").should == RacePerformanceStatus[:dnf]
      RacePerformanceStatus.from_time("Disq").should == RacePerformanceStatus[:disqualified]
      RacePerformanceStatus.from_time("x").should == RacePerformanceStatus[:dnf]
    end
  end
end
