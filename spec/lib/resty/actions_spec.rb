require 'spec_helper'

describe Resty::Actions do

  let(:transport) { mock('transport') }
  let(:wrapped) { mock }
  let(:factory) { mock('factory', :transport => transport, :wrap => wrapped) }

  describe "#perform!" do
  
    subject { Resty::Actions.new(factory, 'bake' => { ':href' => 'http://blah.blah/123/bake', ':method' => 'POST' }) }
  
    it "should call the action when performed!" do
      transport.should_receive(:request_json).with('http://blah.blah/123/bake', 'POST', nil, nil)
      subject.perform!('bake')
    end
  
    it "should raise error on unknown action" do
      lambda { subject.perform!('fry') }.should raise_error
    end
    
    it "should pass parameters" do
      transport.should_receive(:request_json).with('http://blah.blah/123/bake', 'POST', { blah: 'bling' }.to_json, 'application/json')
      subject.perform!('bake', blah: 'bling')
    end
    
    it "should wrap the result" do
      transport.stub!(:request_json => { blah: 'bling' })
      subject.perform!('bake') == wrapped
    end

  end

end
