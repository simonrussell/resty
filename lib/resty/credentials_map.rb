class Resty::CredentialsMap

  ENDS_WITH_SLASH = /\/$/

  def initialize(credentials = {})
    @credentials = Hash[credentials.map do |matcher, username_and_password|
      [regexify(matcher), username_and_password]
    end]
  end

  def find(url)
    @credentials.each do |matcher, username_and_password|
      return username_and_password if matches?(matcher, url)
    end
    
    nil
  end
  
  private
  
  def matches?(matcher, url)
    url = url.sub(/\?.+$/, '')
    matcher =~ url || (url !~ ENDS_WITH_SLASH && matcher =~ (url + '/'))
  end
  
  def regexify(matcher)
    if matcher.is_a?(String)
      /^#{Regexp.escape(matcher)}/
    else
      matcher
    end
  end

end
