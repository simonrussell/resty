require 'spec_helper'

describe Resty::Factory do

  let(:transport) { mock('transport') }
  let(:factory) { Resty::Factory.new(transport) }
  
  describe "initialization" do
    subject { factory }
    
    its(:transport) { should == transport }
  end
  
  describe "#from" do
    let(:data) { { 'a' => 12 } }
    
    subject { factory.from(data) }
    
    it { should be_a(Resty) }
    it { subject._attributes.factory.should == factory }
    it { subject._attributes.data.should == data }
  end

  describe "#wrap" do
    ["string", 0, nil, true, false].each do |input|
      it "should return #{input.to_json} as itself" do
        factory.wrap(input).should eql(input)
      end
    end

    it "should wrap object into a Resty" do
      factory.wrap({}).should be_a(Resty)
    end

    it "should wrap array into a Resty" do
      factory.wrap([]).should be_a(Resty)
    end

  end

  describe "#from_param" do
      
    it "should decode the param and create a new Resty" do
      href = "http://bob.bob/"
      factory.from_param(Resty.encode_param(href))._href.should == href
    end
    
    it "should return a non-url resty for nil param" do
      factory.from_param(nil)._href.should be_nil
    end
    
  end

end
