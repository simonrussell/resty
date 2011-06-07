class Resty::Attributes

  attr_reader :href

  def initialize(data)
    @href = data[':href']
    @populated = !@href || data.length > 1    # a hack for now
    @data = data
  end

  def key?(name)
    populate! unless populated?
    @data.key?(name)
  end

  def [](name)
    populate! unless populated?
    Resty.wrap(@data[name])
  end

  def populated?
    @populated
  end

  def populate!
    @data = Resty::Transport.request_json(@href)
    @populated = true
  end

  def populated_data
    populate!
    @data
  end
  
  def actions
    unless @actions
      populate! unless populated?
      @actions = Resty::Actions.new(@data[':actions'])
    end
      
    @actions
  end

end
