class Resty::Attributes

  attr_reader :href

  def initialize(data)
    @href = data[':href']
    @data = data
  end

  def key?(name)
    @data.key?(name)
  end

  def [](name)
    Resty.wrap(@data[name])
  end

end
