require 'rubygems'
require 'bundler'

ENV["RAILS_ENV"] = "test"

begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

version = Bundler.load.specs.find {|spec| spec.name == "rails"}.version.to_s

if version >= "3.0.0"
  require "action_controller/railtie"
  require "rails/test_unit/railtie"

  class TestApp < Rails::Application
    config.active_support.deprecation = :stderr
    config.logger = Logger.new(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i ? 'NUL:' : '/dev/null')
  end

  TestApp.initialize!

  TestApp.routes.draw do
    match '/test' => "test#test", :via => [:get, :put]
    match ':controller/:action'
  end

  class ActionController::TestCase
    def setup
      @routes = TestApp.routes
    end
  end
else
  require "action_controller"
  require "active_support"

  MissingSourceFile::REGEXPS.push([/^cannot load such file -- (.+)$/i, 1])

  ActionController::Routing::Routes.draw do |map|
    map.connect '/test', :controller => :test, :action => :test, :conditions => { :method => [:get, :put] }
    map.connect ':controller/:action'
  end

  ActionDispatch = ActionController
end

require 'test/unit'
require 'shoulda'

require 'charcoal'


