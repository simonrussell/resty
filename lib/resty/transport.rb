class Resty::Transport
  
  class<<self
    attr_accessor :default_href_params
  end

  def self.request_json(href, method = 'GET', body = nil, content_type = nil)
  
    headers = content_type ? { :content_type => content_type } : nil
    payload = body || ''

    if default_href_params
      seperator = (href =~ /\?/ ? '&' : '?')
      params = default_href_params.to_a.map{|p| p.join('=')}.join('&')
      href = href + seperator + params
    end
  
    response = RestClient::Request.execute(
      :url => href,
      :method => method,
      :payload => payload,
      :headers => headers
    )
    
    if !(response.nil? || response =~ /\A\s*\Z/)
      JSON.parse(response)
    elsif !response.nil? && response.headers[:location]
      { ':href' => response.headers[:location] }
    else
      nil
    end
  end

end
