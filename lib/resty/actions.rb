class Resty::Actions

  def initialize(definitions)
    @definitions = definitions || {}
  end
  
  def perform!(name)
    raise "unknown action #{name}" unless exist?(name)
    href = @definitions[name].fetch(':href') { raise "no href for action #{name}" }
    method = @definitions[name].fetch(':method') { raise "no method for action #{name}" }
    
    Resty::Transport.request_json(href, method)
  end

  def exist?(name)
    @definitions.key?(name)
  end

end
