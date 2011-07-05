Gem::Specification.new do |spec|
  spec.name        = 'wowget'
  spec.version     = '0.2.3'
  spec.date        = '2011-07-05'
  spec.summary     = "wowget"
  spec.description = "Ruby API to wowhead.com's item and spell database."
  spec.authors     = ["Ben Darlow"]
  spec.email       = 'ben@kapowaz.net'
  spec.files       = Dir["lib/**/*"]
  spec.test_files  = Dir["spec/*"]
  spec.homepage    = 'http://github.com/kapowaz/wowget'
  spec.required_ruby_version = '>= 1.9.2'
  spec.add_runtime_dependency 'nokogiri', ['~> 1.4']
  spec.add_runtime_dependency 'json', ['~> 1.4']
  spec.add_development_dependency 'rspec', ['~> 2.6']
end