class Resty::Attributes

  def initialize(data)
    @data = data
  end

  def key?(name)
    @data.key?(name)
  end

  def [](name)
    @data[name]
  end

end
