require 'spec_helper'

describe Resty::CredentialsMap do

  let(:credentials1) { ['user', 'password'] }
  let(:credentials2) { ['user2', 'password2'] }
  
  let(:credentials) do
    {
      'http://fish.com/' => credentials1,
      %r{http://blah.com/\d+/} => credentials2
    }
  end
  
  let(:map) { Resty::CredentialsMap.new(credentials) }

  describe "#find" do
    subject { map.find(url) }
    
    context "string url" do
      context "with base url" do
        let(:url) { 'http://fish.com' }
        it { should == credentials1 }
      end
      
      context "with base url + query" do
        let(:url) { 'http://fish.com?and=stuff' }
        it { should == credentials1 }
      end      
      
      context "with base url + slash" do
        let(:url) { 'http://fish.com/' }
        it { should == credentials1 }
      end
      
      context "with base url + path" do
        let(:url) { 'http://fish.com/inner/path' }
        it { should == credentials1 }
      end
    end
    
    context "regex url" do
      context "with base url" do
        let(:url) { 'http://blah.com/12' }
        it { should == credentials2 }
      end
      
      context "with base url + query" do
        let(:url) { 'http://blah.com/12?and=stuff' }
        it { should == credentials2 }
      end
            
      context "with base url + slash" do
        let(:url) { 'http://blah.com/12/' }
        it { should == credentials2 }
      end
      
      context "with base url + path" do
        let(:url) { 'http://blah.com/45/inner/path' }
        it { should == credentials2 }
      end
    end    
    
    context "bad url" do
      let(:url) { 'http://unknown.com' }
      it { should be_nil }
    end

  end
  
end
