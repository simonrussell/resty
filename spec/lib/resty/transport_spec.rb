require 'spec_helper'

describe Resty::Transport do

  let(:shamrack) { ShamRack.at('blah.blah').stub }
  before { shamrack }
  after { ShamRack.unmount_all }

  describe "::request_json" do

    let(:output) do
      {
        ':http' => 'http://blah.blah',
        'name' => 'fish'
      }
    end

    before do
      shamrack.register_resource('/', output.to_json, 'application/json')
      shamrack.handle do |request|
        [201, {'Location' => 'http://blah.blah'}, ['']] if request.path_info == '/redirect'
      end
    end

    it "should decode json for successful response" do
      Resty::Transport.request_json('http://blah.blah', 'GET').should == output
    end

    it "should return href hash for redirect" do
      Resty::Transport.request_json('http://blah.blah/redirect', 'GET').should == { ':href' => 'http://blah.blah' }
    end

    it "should raise error on not found" do
      lambda { Resty::Transport.request_json('http://blah.blah/not-exist', 'GET') }.should raise_error(RestClient::ResourceNotFound)
    end

  end

end
