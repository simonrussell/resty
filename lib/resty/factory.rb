class Resty::Factory

  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  # @return [Resty] A new Resty constructed from the given hash.
  # @example
  #   r = Resty.from('name' => 'Bob')
  def from(data)
    Resty.new(Resty::Attributes.new(self, data))
  end

  # @return [Resty] A new Resty created from the URL encoded in the input.
  def from_param(s)
    href(Resty.decode_param(s))
  end

  # @return [Resty] A new Resty pointing at the given URL.
  # @example
  #   r = Resty.href('http://fish.fish/')
  def href(href)
    from(':href' => href)
  end

  # @return The input object, or a Resty wrapping if it's a Hash or Array.
  def wrap(object)
    case object
    when Hash
      from(object)
    when Array
      from(':items' => object)
    else
      object
    end
  end

end
