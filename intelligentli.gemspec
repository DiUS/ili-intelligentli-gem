Gem::Specification.new do |s|
  s.name        = 'intelligentli'
  s.version     = '0.0.2'
  s.date        = '2015-04-01'
  s.summary     = "Intelligent.li api utils"
  s.description = "A gem for authenticated access to intelligent.li"
  s.authors     = ["Voon Siong Wong"]
  s.email       = 'vwong@dius.com.au'
  s.files       = ["lib/intelligentli.rb"]

  s.add_runtime_dependency "gibberish"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "httmultiparty"
end
