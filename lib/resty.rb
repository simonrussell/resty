require 'rest-client'
require 'json'

class Resty
  
  def initialize(attributes)
    @attributes = attributes
  end

  def _populated_data
    @attributes.populated_data
  end

  def respond_to_missing?(name, include_private)
    @attributes.key?(name.to_s)
  end

  def method_missing(name)
    if @attributes.key?(name.to_s)
      @attributes[name.to_s]
    else
      super
    end
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

end

%w(attributes transport).each do |f|
  require File.join(File.dirname(__FILE__), 'resty', f)
end
