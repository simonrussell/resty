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

    context "populated" do
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

    context "unpopulated" do
      let(:output) do
        {
          ':href' => 'http://bob.com',
          'name' => 'fred'
        }
      end
      subject { Resty::Attributes.new(':href' => output[':href']) }
      before { Resty::Transport.stub!(:request_json => output) }

      it "should populate from the href" do
        subject['name'].should == 'fred'
      end
    end
    

  end
  
  describe "actions" do
    subject { Resty::Attributes.new(':actions' => { 'bake' => { } }) }
    its(:actions) { should be_a(Resty::Actions) }
  end

end
