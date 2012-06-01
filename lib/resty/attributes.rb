class Resty::Attributes

  attr_reader :href
  attr_reader :factory
  attr_reader :data
  
  def initialize(factory, data)
    @factory = factory
    @href = data[':href']
    @fully_populated = if @href
                         !data[':partial'] && data.length > 1
                       else
                         true
                       end

    @data = data
    @wrapped = {}
  end

  def key?(name)
    until_populated do
      key_variants(name) do |key|
        return true
      end
    end

    false
  end
 
  def [](name)
    until_populated do
      key_variants(name) do |key|
        return wrap_data(key)
      end
    end

    nil
  end

  def items
    populate! unless populated?
    @wrapped[':items'] ||= (@data[':items'] || []).map { |item| @factory.wrap(item) }
  end
    
  def populated?(key = nil)
    @fully_populated
  end

  def populate!
    new_data = @factory.transport.request_json(@href)

    @data = case new_data
            when Array
              { ':href' => @href, ':items' => new_data }
            else
              new_data
            end
            
    @fully_populated = true
    @wrapped = {}
  end

  def populated_data
    populate! unless populated?
    @data
  end
  
  def actions
    unless @actions
      populate! unless populated?
      @actions = Resty::Actions.new(@factory, @data[':actions'])
    end
      
    @actions
  end
  
  private
  
  def wrap_data(key)
    @wrapped[key] ||= @factory.wrap(@data[key])
  end

  def camelize_key(key)
    key.gsub(/_([a-z])/) { $1.upcase }
  end

  def key_variants(name)
    yield name if @data.key?(name)

    camelized_name = camelize_key(name)
    yield camelized_name if camelized_name != name && @data.key?(camelized_name)
  end

  def until_populated
    yield
    
    unless populated?
      populate!
      yield
    end
  end
  
end
