# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "charcoal"
  gem.homepage = "http://github.com/steved555/charcoal"
  gem.license = "MIT"
  gem.summary = %Q{Cross-Origin helper for Rails}
  gem.description = %Q{Helps you support JSONP and CORS in your Rails app}
  gem.email = "sdavidovitz@zendesk.com"
  gem.authors = ["Steven Davidovitz"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'appraisal'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc 'Test the plugin under all supported Rails versions.'
task :all => ["appraisal:cleanup", "appraisal:install"] do
  exec('rake appraisal test')
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
