require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'rake/testtask'
require "standard/rake"

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'yard'
YARD::Rake::YardocTask.new
task default: [:test, :standard]
