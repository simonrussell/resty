class Resty::Transport
  
  def self.request_json(href, method = 'GET', body = nil, content_type = nil)
  
    headers = content_type ? { :content_type => content_type } : nil
    payload = body || ''
  
    response = RestClient::Request.execute(
      :url => href,
      :method => method,
      :payload => payload,
      :headers => headers
    )
    
    if !(response.nil? || response =~ /\A\s*\Z/)
      JSON.parse(response)
    elsif response.headers[:location]
      { ':href' => response.headers[:location] }
    else
      nil
    end
  end

end
