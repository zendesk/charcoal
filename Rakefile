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

require 'appraisal'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc 'Test the plugin under all supported Rails versions.'
task :all => ["appraisal:install"] do
  exec('rake appraisal test')
end

task :default => :all

require 'yard'
YARD::Rake::YardocTask.new
