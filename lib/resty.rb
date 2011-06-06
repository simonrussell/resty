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
  
end

require File.join(File.dirname(__FILE__), 'resty', 'attributes')
