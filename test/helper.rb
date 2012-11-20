require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "action_controller/railtie"
require "rails/test_unit/railtie"

require 'test/unit'
require 'shoulda'

require 'charcoal'

class TestApp < Rails::Application
  config.active_support.deprecation = :stderr
end

TestApp.initialize!

TestApp.routes.draw do
  match ':controller/:action'
end

class ActionController::TestCase
  def setup
    @routes = TestApp.routes
  end
end
