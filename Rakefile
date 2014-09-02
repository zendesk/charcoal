require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc 'Test the plugin under all supported Rails versions.'
task :all do
  exec('appraisal install && appraisal rake test')
end

task :default => :all

require 'yard'
YARD::Rake::YardocTask.new
