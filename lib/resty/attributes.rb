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

  private

  def populate!
    @data = Resty::Transport.load_json(@href)
  end

end
