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

    subject { Resty::Attributes.new('bob' => 'biscuits', 'bobTownNewJersey' => 'bobby', 'strange_birds' => 2) }

    it "should return false for unknown attribute" do
      subject.key?('fred').should be_false
    end    

    it "should return known attribute" do
      subject.key?('bob').should be_true
    end
    
    it "should pass through camelized names" do
      subject.should be_key('bobTownNewJersey')
    end
    
    it "should camelize attribute names" do
      subject.should be_key('bob_town_new_jersey')
    end

    it "should only camelize if not found" do
      subject.should be_key('strange_birds')
    end

  end

  describe "[]" do

    context "populated" do
      subject { Resty::Attributes.new('bob' => 'biscuits', 'bobTownNewJersey' => 'bobby', 'strange_birds' => 2) }

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

      it "should pass through camelized names" do
        subject['bobTownNewJersey'].should == 'bobby'
      end
      
      it "should camelize attribute names" do
        subject['bob_town_new_jersey'].should == 'bobby'
      end

      it "should only camelize if not found" do
        subject['strange_birds'].should == 2
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
