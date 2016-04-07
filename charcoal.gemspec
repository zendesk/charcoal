require './lib/charcoal/version'

Gem::Specification.new('charcoal', Charcoal::VERSION) do |s|
  s.authors = ["Steven Davidovitz"]
  s.description = "Helps you support JSONP and CORS in your Rails app"
  s.summary = "Cross-Origin helper for Rails"
  s.email = "sdavidovitz@zendesk.com"
  s.homepage = "https://github.com/zendesk/charcoal"

  s.files = Dir.glob('{lib,config,app}/**/*')

  s.licenses = ['MIT']

  s.add_runtime_dependency 'activesupport', '>= 3.2.21', '< 5.1'
  s.add_runtime_dependency 'actionpack', '>= 3.2.21', '< 5.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'wwtd'
  s.add_development_dependency 'bump'
  s.add_development_dependency 'yard', '~> 0.7'

  s.add_development_dependency 'shoulda', '~> 3.0'
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'mocha'
end
