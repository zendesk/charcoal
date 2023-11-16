require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"
require "yard"

YARD::Rake::YardocTask.new

Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end

task default: [:test, :standard]
