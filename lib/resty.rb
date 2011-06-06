require 'rest-client'

class Resty
  
  def initialize(attributes)
    @attributes = attributes
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
    else
      object
    end
  end

end

%w(attributes transport).each do |f|
  require File.join(File.dirname(__FILE__), 'resty', f)
end
