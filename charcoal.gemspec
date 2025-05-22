require "./lib/charcoal/version"

Gem::Specification.new("charcoal", Charcoal::VERSION) do |s|
  s.authors = ["Steven Davidovitz"]
  s.description = "Helps you support JSONP and CORS in your Rails app"
  s.summary = "Cross-Origin helper for Rails"
  s.email = "sdavidovitz@zendesk.com"
  s.homepage = "https://github.com/zendesk/charcoal"

  s.required_ruby_version = ">= 3.2"

  s.files = Dir.glob("{lib,config,app}/**/*")

  s.licenses = ["MIT"]

  s.add_dependency "activesupport", ">= 6.1"
  s.add_dependency "actionpack", ">= 6.1"
end
