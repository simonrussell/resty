require 'spec_helper'

describe Resty::Transport do

  let(:shamrack) { ShamRack.at('blah.blah').stub }
  before { shamrack }
  after { ShamRack.unmount_all }

  describe "::load_json" do

    let(:output) do
      {
        ':http' => 'http://blah.blah',
        'name' => 'fish'
      }
    end

    before do
      shamrack.register_resource('/', output.to_json, 'application/json')
    end

    it "should decode json for successful response" do
      Resty::Transport.load_json('http://blah.blah').should == output
    end

    it "should raise error on not found" do
      lambda { Resty::Transport.load_json('http://blah.blah/not-exist') }.should raise_error(RestClient::ResourceNotFound)
    end

  end

end
