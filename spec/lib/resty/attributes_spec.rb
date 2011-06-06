require 'spec_helper'

describe Resty::Attributes do

  describe "#key?" do

    subject { Resty::Attributes.new('bob' => 'biscuits') }

    it "should return false for unknown attribute" do
      subject.key?('fred').should be_false
    end    

    it "should return known attribute" do
      subject.key?('bob').should be_true
    end    
    
  end

  describe "[]" do

    subject { Resty::Attributes.new('bob' => 'biscuits') }

    it "should return nil for unknown attribute" do
      subject['fred'].should be_nil
    end    

    it "should return known attribute" do
      subject['bob'].should == 'biscuits'
    end    

  end

end
