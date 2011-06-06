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

  describe "::from" do
    it "should create attributes etc" do
      Resty.from(':href' => 'blah').should be_a(Resty)
    end
  end

  describe "::wrap" do
    
    ["string", 0, nil, true, false].each do |input|
      it "should return #{input.to_json} as itself" do
        Resty.wrap(input).should eql(input)
      end
    end

    it "should wrap object into a Resty" do
      Resty.wrap({}).should be_a(Resty)
    end

  end

  context "big picture" do

    subject do
      Resty.from(
        ':href' => 'http://blah.blab/bob/123',
        'name' => 'Bob Bobbington',
        'address' => {
          'street' => 'Fish St'
        },
        'company' => {
          ':href' => 'http://company.company'
        }
      )
    end

    it "should work nested" do
      subject.address.street.should == 'Fish St'
    end
  end

end
