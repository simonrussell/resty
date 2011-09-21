require 'spec_helper'

describe Resty::Transport do

  let(:shamrack) { ShamRack.at('blah.blah').stub }
  before { shamrack }
  after { ShamRack.unmount_all }

  describe "self::default_href_params" do
    let(:params) { {blah: 'blah'} }
    after { Resty::Transport.default_href_params = nil }
    it "should allow set/get" do
      Resty::Transport.default_href_params = params
      Resty::Transport.default_href_params.should == params
    end
  end

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

    it "should default the method" do
      Resty::Transport.request_json('http://blah.blah').should == output
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

    context "when default href params are set" do
      let(:default_href_params) { {someparam: 'somevalue'} }
      before { Resty::Transport.stub(:default_href_params => default_href_params) }
      subject { Resty::Transport.request_json(url) }

      context "when original href has no params" do
        let(:url) { 'http://blah.blah' }

        it "should append the default href params" do
          RestClient::Request.should_receive(:execute).with(hash_including({
            url: "http://blah.blah?someparam=somevalue"
          }))
          subject
        end
      end

      context "when original href has params" do
        let(:url) { 'http://blah.blah?other=params' }

        it "should append the default href params" do
          RestClient::Request.should_receive(:execute).with(hash_including({
            url: "http://blah.blah?other=params&someparam=somevalue"
          }))
          subject
        end
      end
    end

  end


end
