require File.dirname(__FILE__) + '/../spec_helper'

describe ActiveSupport::Duration do
  before do
    @timecode = "05:27:25"
    @duration = ActiveSupport::Duration.parse(@timecode)
  end
  
  describe "#parse" do
    it "should instantiate from a delimited string" do
      @duration.should == 5.hours + 27.minutes + 25.seconds
    end
  end
    
  describe "#timecode" do
    it "should return a timecode string" do
      @duration.timecode.should == @timecode
    end
  end
end

describe Numeric do
  before do
    @timecode = "05:27:25"
  end

  describe "#to_timecode" do
    it "should return a timecode string" do
      19645.to_timecode.should == @timecode
    end
  end
end

describe String do
  before do
    @timecode = "05:27:25"
  end

  describe "#to_seconds" do
    it "should return a duration of the right number of seconds" do
      @timecode.seconds.should == 19645
    end
  end
end
