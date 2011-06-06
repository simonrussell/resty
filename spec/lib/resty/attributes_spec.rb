require 'spec_helper'

describe Resty::Attributes do

  describe "#href" do

    context "with href supplied" do
      subject { Resty::Attributes.new(':href' => 'blah') }
      its(:href) { should == 'blah' }
    end

    context "without href supplied" do
      subject { Resty::Attributes.new({}) }
      its(:href) { should be_nil }
    end

  end

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

    it "should wrap the result" do
      Resty.should_receive(:wrap).with('biscuits')
      subject['bob']
    end

  end

end
