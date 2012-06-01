require 'rest-client'
require 'json'
require 'base64'

# @author Simon Russell
class Resty
  include Enumerable
  
  # @note Generally, use Resty::from instead of Resty::new.
  def initialize(attributes)
    @attributes = attributes
  end

  # @return [String, nil] The URL of the resource, or nil if none present.
  def _href
    @attributes.href
  end

  def _attributes
    @attributes
  end

  # The data from the resource; will cause the resource to be loaded if it hasn't already occurred.
  # @return [Hash] The data from the resource
  def _populated_data
    @attributes.populated_data
  end

  # Make respond_to? return true to the corresponding magic methods added using {#method_missing}.
  def respond_to_missing?(name, include_private)
    @attributes.key?(name.to_s)
  end
  
  # @return [String, nil] The URL of the resource, encoded for safe insertion into a URL.  Used for Rails routing.
  def to_param
    Resty.encode_param(_href)
  end
  
  # Iterate through each item in the array; doesn't iterate over keys in the hash.
  def each
    @attributes.items.each do |x|
      yield x
    end
  end
  
  def [](index)
    @attributes.items[index]
  end

  def can?(action)
    @attributes.actions.exist?(action.to_s)
  end

  # Resty exposes the values and actions from the resource as methods on the object.
  #
  # @example Reading an attribute value
  #   r = Resty.href('http://fish.fish/123')  # { ':href': 'http://fish.fish/123', 'name': 'Bob' }
  #   r.name                                  # => "Bob"
  #
  # @example Checking a boolean value
  #   r = Resty.href('http://fish.fish/123')  # { ':href': 'http://fish.fish/123', 'fun': true }
  #   r.fun?                                  # => true
  #
  # @example Calling an action on the resource
  #   r = Resty.href('http://fish.fish/123')  # { 
  #                                           #   ':href': 'http://fish.fish/123',
  #                                           #   ':actions': {
  #                                           #     'cook': { 
  #                                           #       ':href': 'http://fish.fish/123/cook'
  #                                           #       ':method': 'POST'
  #                                           #     } 
  #                                           #   }
  #                                           # }
  #   r.cook!
  #
  # @example Calling an action on the resource with params
  #   r = Resty.href('http://fish.fish/123')
  #   r.cook!(style: 'lightly', flavoursomeness: 12)  # this will cause those parameters to be posted with the action
  def method_missing(name, *args)
    if name =~ /^(.+)!$/
      if @attributes.actions.exist?($1)
        @attributes.actions.perform!($1, *args)
      else
        super
      end
    elsif name =~ /^(.+)\?$/
      !!@attributes[$1]
    elsif @attributes.key?(name.to_s)
      @attributes[name.to_s]
    else
      super
    end
  end

  def to_s
    super.gsub('>', _href ? " #{_href}>" : " no-href>")
  end

  def self.default_factory
    @default_factory ||= Resty::Factory.new(Resty::Transport.new)
  end

  # @return [Resty] A new Resty constructed from the given hash.
  # @example
  #   r = Resty.from('name' => 'Bob')
  def self.from(data)
    default_factory.from(data)
  end

  # @return [Resty] A new Resty pointing at the given URL.
  # @example
  #   r = Resty.href('http://fish.fish/')
  def self.href(href)
    default_factory.href(href)
  end

  # @return [String] The input encoded for safe use in a URL.
  def self.encode_param(s)
    s && Base64.urlsafe_encode64(s.to_s)
  end
  
  # @return [String] The input (previously encoded using Resty::encode_param) decoded into a string.
  def self.decode_param(s)
    s && Base64.urlsafe_decode64(s.to_s)
  end
  
  # @return [Resty] A new Resty created from the URL encoded in the input.
  def self.from_param(s)
    default_factory.from_param(s)
  end
  
end

%w(attributes transport actions factory credentials_map).each do |f|
  require File.join(File.dirname(__FILE__), 'resty', f)
end
