require_relative 'lib/charcoal/version'

Gem::Specification.new('charcoal', Charcoal::VERSION) do |s|
  s.authors = ["Steven Davidovitz"]
  s.description = "Helps you support JSONP and CORS in your Rails app"
  s.summary = "Cross-Origin helper for Rails"
  s.email = "sdavidovitz@zendesk.com"
  s.homepage = "http://github.com/steved555/charcoal"

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]

  s.files = `git ls-files config lib app`.split("\n")

  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'activesupport', '>= 2.3.5', '< 5'
  s.add_runtime_dependency 'actionpack', '>= 2.3.5', '< 5'
end
