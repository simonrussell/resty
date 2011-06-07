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
  end

end
