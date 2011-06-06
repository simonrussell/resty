class Resty::Transport
  
  def self.load_json(href)
    JSON.parse(RestClient.get(href))
  end

end
