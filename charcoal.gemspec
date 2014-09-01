lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'charcoal/version'

Gem::Specification.new do |s|
  s.name = "charcoal"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Davidovitz"]
  s.date = "2013-12-24"
  s.description = "Helps you support JSONP and CORS in your Rails app"
  s.email = "sdavidovitz@zendesk.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".travis.yml",
    "Appraisals",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "charcoal.gemspec",
    "gemfiles/rails_2.3.gemfile",
    "gemfiles/rails_3.2.gemfile",
    "gemfiles/rails_4.0.gemfile",
    "gemfiles/rails_4.1.gemfile",
    "gemfiles/rails_4.2.gemfile",
    "lib/charcoal.rb",
    "lib/charcoal/controller_filter.rb",
    "lib/charcoal/cors.rb",
    "lib/charcoal/cors_controller.rb",
    "lib/charcoal/cors_helper.rb",
    "lib/charcoal/jsonp.rb",
    "lib/charcoal/version.rb",
    "test/cors_controller_test.rb",
    "test/cors_test.rb",
    "test/filters_test.rb",
    "test/helper.rb",
    "test/jsonp_test.rb"
  ]
  s.homepage = "http://github.com/steved555/charcoal"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Cross-Origin helper for Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_runtime_dependency(%q<actionpack>, [">= 2.3.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
    else
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 2.3.5"])
      s.add_dependency(%q<actionpack>, [">= 2.3.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 2.3.5"])
    s.add_dependency(%q<actionpack>, [">= 2.3.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
  end
end

