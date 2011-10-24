Gem::Specification.new do |s|

  s.name = 'resty'
  s.version = '0.5.0'
  s.summary = 'Simple JSON REST API client wrapper'
  s.description = <<-EOS
                    Resty is designed as a client for a particular type of discoverable REST API; one that returns JSON, and 
                    where that JSON has particular keys which enable navigation of the data graph.
                  EOS

  s.author = 'Simon Russell'
  s.email = 'spam+resty@bellyphant.com'
  s.homepage = 'http://github.com/simonrussell/resty'
  
  s.executables << 'resty'
  
  s.add_dependency 'rest-client', '~> 1.6.3'
  s.add_dependency 'json', '~> 1.5'

  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + ['LICENSE', 'README.md']
  
end
