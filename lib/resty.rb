require 'rest-client'
require 'json'
require 'base64'

class Resty
  
  def initialize(attributes)
    @attributes = attributes
  end

  def _href
    @attributes.href
  end

  def _populated_data
    @attributes.populated_data
  end

  def respond_to_missing?(name, include_private)
    @attributes.key?(name.to_s)
  end
  
  def to_param
    Resty.encode_param(_href)
  end

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

  def self.from(data)
    new(Resty::Attributes.new(data))
  end

  def self.wrap(object)
    case object
    when Hash
      from(object)
    when Array
      from(':items' => object)
    else
      object
    end
  end

  def self.href(href)
    from(':href' => href)
  end

  def self.encode_param(s)
    s && Base64.urlsafe_encode64(s.to_s)
  end
  
  def self.decode_param(s)
    s && Base64.urlsafe_decode64(s.to_s)
  end
  
  def self.from_param(s)
    href(decode_param(s))
  end
  
end

%w(attributes transport actions).each do |f|
  require File.join(File.dirname(__FILE__), 'resty', f)
end
