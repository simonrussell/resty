require 'spec_helper'

describe Resty::Attributes do

  let(:transport) { mock('transport') }
  let(:factory) { Resty::Factory.new(transport) }
  let(:attributes) { Resty::Attributes.new(factory, data) }
  
  describe "#href" do
    subject { attributes }
    
    context "with href supplied" do
      let(:data) { {':href' => 'blah'} }
      its(:href) { should == 'blah' }
    end

    context "without href supplied" do
      let(:data) { {} }
      its(:href) { should be_nil }
    end

  end

  describe "#key?" do
    let(:data) { { 'bob' => 'biscuits', 'bobTownNewJersey' => 'bobby', 'strange_birds' => 2 } }
    subject { attributes }

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
  
  describe "attribute memoization" do
    let(:data) { { 'bob' => 'biscuits', 'bobTownNewJersey' => 'bobby', 'strange_birds' => 2, ':items' => [1,2,3] } }
    subject { attributes }
    
    it "should return same wrapped attribute for two gets" do
      subject['bob'].should eql subject['bob']
    end
  end

  describe "#items" do
    subject { attributes }
    
    context "with :items" do
      let(:items) { [1, 2, { 'fish' => 'biscuits' }] }
      let(:data) { { ':items' => items } }
      
      it "should return the wrapped items" do
        subject.items[0].should == 1
        subject.items[1].should == 2
        subject.items[2].should be_a(Resty)
      end
    end
    
    context "without :items" do
      let(:data) { {} }
    
      it "should not call the block from each" do
        subject.items.should == []
      end
    end
  
  end

  context "populated" do
    let(:data) { { 'bob' => 'biscuits', 'bobTownNewJersey' => 'bobby', 'strange_birds' => 2, ':items' => [1,2,3] } }
    subject { attributes }

    describe "#[]" do
      it "should return nil for unknown attribute" do
        subject['fred'].should be_nil
      end    

      it "should return known attribute" do
        subject['bob'].should == 'biscuits'
      end    

      it "should wrap the result" do
        factory.should_receive(:wrap).with('biscuits')
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

    describe "#key?" do
      it "should return false for unknown attribute" do
        subject.should_not be_key('fred')
      end

      it "should return known attribute" do
        subject.should be_key('bob')
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
  end

  context "unpopulated" do
    let(:output) do
      {
        ':href' => 'http://bob.com',
        'name' => 'fred'
      }
    end

    let(:transport) { mock('transport', :request_json => output) }
    let(:data) { { ':href' => output[':href'], 'age' => 900, ':partial' => true } }
    subject { attributes }
    
    describe "#[]" do
      it "should populate from the href" do
        subject['name'].should == 'fred'
      end

      it "should use the supplied info" do
        subject['age'].should == 900
      end
      
      it "should call the transport if attribute not present" do
        transport.should_receive(:request_json).with(output[':href'])
        subject['name']
      end

      it "should not call the transport if attribute present" do
        transport.should_not_receive(:request_json).with(output[':href'])
        subject['age']
      end
    end

    describe "#key?" do
      it "should populate from the href" do
        subject.should be_key('name')
      end

      it "should use the supplied info" do
        subject.should be_key('age')
      end
      
      it "should call the transport if attribute not present" do
        transport.should_receive(:request_json).with(output[':href'])
        subject.key?('name')
      end

      it "should not call the transport if attribute present" do
        transport.should_not_receive(:request_json).with(output[':href'])
        subject.key?('age')
      end
    end
  end
  
  context "unpopulated with array at end" do
    let(:output) { [1, 2, 3] }
    let(:href) { 'http://bob.com' }
    let(:transport) { mock('transport', :request_json => output) }
    let(:data) { { ':href' => href } }

    subject { attributes }
    
    describe "#[]" do
      it "should populate from the href" do
        subject.items.should == [1,2,3]
      end
      
      it "should fill in the href from the original href" do
        subject.href.should == href
      end
    end
  end
    
  describe "#populated?" do
    subject { attributes }
  
    context "href" do
      context "with full info" do
        let(:data) { { ':href' => 'http://fish.fish', 'name' => 'wilfred', 'age' => 96 } }
        it { should be_populated }
      end
    
      context "with no info" do
        let(:data) { { ':href' => 'http://fish.fish' } }
        it { should_not be_populated }
      end

      context "with partial info" do
        let(:data) { { ':href' => 'http://fish.fish', 'name' => 'wilfred', ':partial' => true } }
        it { should_not be_populated }
      end
    end
    
    context "no href" do
      context "with full info" do
        let(:data) { { 'name' => 'wilfred', 'age' => 96 } }
        it { should be_populated }
      end
    
      context "with no info" do
        let(:data) { {} }
        it { should be_populated }
      end

      context "with partial info (should ignore partial)" do
        let(:data) { { 'name' => 'wilfred', ':partial' => true } }
        it { should be_populated }
      end
    end

  end  
  
  describe "actions" do
    let(:data) { { ':actions' => { 'bake' => { } } } }
    subject { attributes }
    
    its(:actions) { should be_a(Resty::Actions) }
  end

end
