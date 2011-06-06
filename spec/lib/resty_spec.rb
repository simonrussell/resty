require 'spec_helper'

describe Resty do

  describe "attribute methods" do

    let(:attributes) { { 'name' => 'bob' } }
    subject { Resty.new(attributes) }

    it "should respond to known attribute" do
      subject.should respond_to(:name)
    end

    it "should not respond to unknown attribute" do
      subject.should_not respond_to(:biscuits)
    end

    it "should return known attribute when method called" do
      subject.name.should == 'bob'
    end

    it "should raise error for unknown attribute when method called" do
      lambda { subject.biscuits }.should raise_error(NoMethodError)
    end

  end

end
