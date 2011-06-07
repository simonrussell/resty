class Resty::Actions

  def initialize(definitions)
    @definitions = definitions || {}
  end
  
  def perform!(name, parameters = nil)
    raise "unknown action #{name}" unless exist?(name)
    href = @definitions[name].fetch(':href') { raise "no href for action #{name}" }
    method = @definitions[name].fetch(':method') { raise "no method for action #{name}" }
    
    if parameters
      body = parameters.to_json
      mimetype = 'application/json'
    else
      body = nil
      mimetype = nil
    end
    
    Resty::Transport.request_json(href, method, body, mimetype)
  end

  def exist?(name)
    @definitions.key?(name)
  end

end
