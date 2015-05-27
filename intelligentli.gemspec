Gem::Specification.new do |s|
  s.name        = 'intelligentli'
  s.version     = '0.1.2'
  s.date        = '2015-05-27'
  s.summary     = "Intelligent.li api utils"
  s.description = "A gem for authenticated access to intelligent.li"
  s.authors     = ["Voon Siong Wong"]
  s.email       = 'vwong@dius.com.au'
  s.files       = Dir['lib/**/*.rb']

  s.add_runtime_dependency "gibberish"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "httmultiparty"
  s.add_runtime_dependency 'faye-websocket'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'timecop'
end
