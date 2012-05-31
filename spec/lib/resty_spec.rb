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
  
  describe "query methods" do
    
    subject { Resty.from('fun' => true, 'boring' => false, 'integer' => 1, 'nullish' => nil) }
    
    it { subject.fun?.should == true }
    it { subject.boring?.should == false }
    it { subject.integer?.should == true }
    it { subject.nullish?.should == false }
    
  end
  
  describe "action methods" do
  
    subject { Resty.from(':actions' => { 'bake' => { ':href' => 'http://blah.blah/bake', ':method' => 'POST' } }) }
    before { Resty::Transport.stub(:request_json) }
    
    it "should respond to known action" do
      Resty::Transport.should_receive(:request_json).with('http://blah.blah/bake', 'POST', nil, nil)
      subject.bake!
    end
    
    it "should respond to known action" do
      Resty::Transport.should_receive(:request_json).with('http://blah.blah/bake', 'POST', { name: 123 }.to_json, 'application/json')
      subject.bake!(name: 123)
    end

    it "should raise NoMethodError on unknown action" do
      lambda { subject.fry! }.should raise_error(NoMethodError)
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

    it "should wrap array into a Resty" do
      Resty.wrap([]).should be_a(Resty)
    end

  end
  
  describe "::encode_param" do
  
    it "should encode strict url-safe" do
      Base64.should_receive(:urlsafe_encode64).with('123').and_return('456')
      Resty.encode_param('123').should == '456'
    end

    it "should encode nil to nil" do
      Resty.encode_param(nil).should be_nil
    end
  
  end

  describe "::decode_param" do
  
    it "should decode strict url-safe" do
      Base64.should_receive(:urlsafe_decode64).with('456').and_return('123')
      Resty.decode_param('456').should == '123'
    end

    it "should decode nil to nil" do
      Resty.decode_param(nil).should be_nil
    end
  
  end
  
  describe "::from_param" do
      
    it "should decode the param and create a new Resty" do
      href = "http://bob.bob/"
      Resty.from_param(Resty.encode_param(href))._href.should == href
    end
    
    it "should return a non-url resty for nil param" do
      Resty.from_param(nil)._href.should be_nil
    end
    
  end
  
  describe "#to_param" do
    
    it "should be good for href-present" do
      href = 'http://fish.fish'
      Resty.href(href).to_param.should == Resty.encode_param(href)
    end
    
    it "should be nil for href-absent" do
      Resty.from({}).to_param.should be_nil
    end
    
  end
  
  describe "#_href" do
    it "should be good for href-present" do
      href = 'http://fish.fish'
      Resty.href(href)._href.should == href
    end
    
    it "should be nil for href-absent" do
      Resty.from({})._href.should be_nil
    end  
  end

  describe "#to_s" do
    it "should work for href-present" do
      r = Resty.href("http://bob.bob")
      r.to_s.should =~ /^#<Resty:0x[a-f\d]+ #{Regexp.escape(r._href)}>$/
    end
    
    it "should work for nil href" do
      Resty.from({}).to_s.should =~ /^#<Resty:0x[a-f\d]+ no-href>$/
    end
  end

  describe "enumerability" do

    context "with :items" do
      let(:items) { [1,2,3] }
      subject { Resty.from('fish' => 12, ':items' => items) }
      
      it { should be_a(Enumerable) }
      
      it "should return the items in order from each" do
        output = []
        subject.each { |x| output << x }
        output.should == items
      end
    end
    
    context "without :items" do
      subject { Resty.from('fish' => 12) }
    
      it { should be_a(Enumerable) }    # we don't know if it's enumerable until we populate the object
      
      it "should not call the block from each" do
        subject.each { |x| fail "should not get here" }
      end
    end
  
  end
  
  describe "#[]" do
    
    let(:items) { stub }
    subject { Resty.new(stub(:items => items)) }
    
    it "should lookup the index in the attributes" do
      items.should_receive(:[]).with(12).and_return('fishy')
      subject[12].should == 'fishy'
    end
    
  end

  context "big picture" do

    let(:shamrack) { ShamRack.at('company.company').stub }
    let(:company_info) do
      {
        ':href' => 'http://company.company',
        'name' => 'Fishtech',
        ':actions' => { 
          'rename' => {
            ':href' => 'http://company.company/rename',
            ':method' => 'POST'
          }
        }
      }
    end
    
    before do
      shamrack.register_resource('/', company_info.to_json, 'application/json')
      shamrack.register_resource('/rename', '')
    end
    
    after { ShamRack.unmount_all }

    subject do
      Resty.from(
        ':href' => 'http://blah.blab/bob/123',
        'name' => 'Bob Bobbington',
        'address' => {
          'street' => 'Fish St'
        },
        'company' => {
          ':href' => 'http://company.company',
        },
        ':actions' => {
          'send_message' => {
            ':href' => 'http://blah.blab/bob/123/messages',
            ':method' => 'POST'
          }
        }
      )
    end

    it "should work nested" do
      subject.address.street.should == 'Fish St'
    end
    
    it "should get nested objects" do
      subject.company.name.should == 'Fishtech'
    end
     
    it "should have actions that work" do
      subject.company.rename!
    end
    
    describe "#can?" do
      it { should be_can(:send_message) }
      it { should_not be_can(:other_action) }
    end
  end

end
