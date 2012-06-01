require 'spec_helper'

describe Resty::Transport do

  let(:shamrack) { ShamRack.at('blah.blah').stub }
  before { shamrack }
  after { ShamRack.unmount_all }

  let(:credentials) { nil }
  let(:credentials_map) { mock('credentials_map', :find => credentials) }
  let(:transport) { Resty::Transport.new(credentials_map: credentials_map) }

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
      transport.request_json('http://blah.blah').should == output
    end

    it "should decode json for successful response" do
      transport.request_json('http://blah.blah', 'GET').should == output
    end

    it "should return href hash for redirect" do
      transport.request_json('http://blah.blah/redirect', 'GET').should == { ':href' => 'http://blah.blah' }
    end

    it "should raise error on not found" do
      lambda { transport.request_json('http://blah.blah/not-exist', 'GET') }.should raise_error(RestClient::ResourceNotFound)
    end

    context "when default href params are set" do
      let(:default_href_params) { {someparam: 'somevalue'} }
      before { transport.default_href_params = default_href_params }
      subject { transport.request_json(url) }

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

    describe "using credentials_map" do
      let(:url) { 'http://blah.blah?other=params' }
      subject { transport.request_json(url) }
    
      context "with no credentials" do
        it "should send nil username and password" do
          RestClient::Request.should_receive(:execute).with(hash_including(
            user: nil,
            password: nil
          ))
          subject
        end        
      end
    
      context "with matching url" do
        let(:username) { 'username' }
        let(:password) { 'fishy' }
        let(:credentials) { [username, password] }
        
        it "should send correct username and password" do
          RestClient::Request.should_receive(:execute).with(hash_including(
            user: username,
            password: password
          ))
          subject
        end        
      end
    
    end

  end

  context "default behaviour through class methods" do
    
    it "should reflect request_json through" do
      Resty::Transport.default.should_receive(:request_json).with(1,2,3).and_return(4)
      Resty::Transport.request_json(1,2,3).should == 4
    end
    
    it "should reflect default_href_params through" do
      Resty::Transport.default_href_params = { :a => :b }
      Resty::Transport.default_href_params.should == { :a => :b }
      Resty::Transport.default.default_href_params.should == { :a => :b }
    end
    
  end

end
