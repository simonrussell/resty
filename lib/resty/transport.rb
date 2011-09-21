class Resty::Transport
  
  class << self
    attr_accessor :default_href_params
  end

  def self.request_json(href, method = 'GET', body = nil, content_type = nil)
  
    headers = content_type ? { :content_type => content_type } : nil
    payload = body || ''

    response = RestClient::Request.execute(
      :url => add_default_params(href),
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

  private
  
  PARAM_REGEX = /\?/
  
  def self.add_default_params(href)
    return href if !default_href_params || default_href_params.empty?
    
    separator = (href =~ PARAM_REGEX ? '&' : '?')
    params = default_href_params.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
    "#{href}#{separator}#{params}"
  end

end
