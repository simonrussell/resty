require 'spec_helper'

describe Resty::Actions do

  describe "#perform!" do
  
    subject { Resty::Actions.new('bake' => { ':href' => 'http://blah.blah/123/bake', ':method' => 'POST' }) }
  
    it "should call the action when performed!" do
      Resty::Transport.should_receive(:request_json).with('http://blah.blah/123/bake', 'POST', nil, nil)
      subject.perform!('bake')
    end
  
    it "should raise error on unknown action" do
      lambda { subject.perform!('fry') }.should raise_error
    end
    
    it "should pass parameters" do
      Resty::Transport.should_receive(:request_json).with('http://blah.blah/123/bake', 'POST', { blah: 'bling' }.to_json, 'application/json')
      subject.perform!('bake', blah: 'bling')
    end

  end

end
