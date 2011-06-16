class Resty::Attributes

  attr_reader :href

  def initialize(data)
    @href = data[':href']
    @populated = if @href
                   !data[':partial'] && data.length > 1
                 else
                   true
                 end

    @data = data
    @wrapped = {}
  end

  def key?(name)
    populate! unless populated?
    @data.key?(translate_key(name))
  end
  
  def translate_key(name)
    populate! unless populated?
    if @data.key?(name)
      name
    elsif @data.key?(camelized_name = camelize_key(name))
      camelized_name
    end
  end

  def [](name)
    populate! unless populated?
    name = translate_key(name)
    @wrapped[name] ||= Resty.wrap(@data[name])
  end

  def items
    populate! unless populated?
    @wrapped[':items'] ||= (@data[':items'] || []).map { |item| Resty.wrap(item) }
  end
    
  def populated?
    @populated
  end

  def populate!
    new_data = Resty::Transport.request_json(@href)
    
    @data = case new_data
            when Array
              { ':href' => @href, ':items' => new_data }
            else
              new_data
            end
            
    @populated = true
  end

  def populated_data
    populate! unless populated?
    @data
  end
  
  def actions
    unless @actions
      populate! unless populated?
      @actions = Resty::Actions.new(@data[':actions'])
    end
      
    @actions
  end
  
  private
  
  def camelize_key(key)
    key.gsub(/_([a-z])/) { $1.upcase }
  end
  
end
