Gem::Specification.new do |s|

  s.name = 'resty'
  s.version = '0.2.1'
  s.summary = 'Simple JSON REST API client wrapper'
  
  s.author = 'Simon Russell'
  s.homepage = 'http://github.com/simonrussell/resty'
  
  s.executables << 'resty'
  
  s.add_dependency 'rest-client', '~> 1.6.3'
  s.add_dependency 'json', '~> 1.5.1'

  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir['lib/**/*.rb'] + Dir['bin/*'] + ['LICENSE']
  
end
