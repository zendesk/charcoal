require 'bundler/setup'

ENV["RAILS_ENV"] = "test"

begin
  require 'byebug'
rescue LoadError
end

require 'minitest/autorun'
require 'mocha/setup'

require 'shoulda'
require 'active_support/version'

require "action_controller/railtie"
require "rails/test_unit/railtie"

class TestApp < Rails::Application
  config.active_support.deprecation = :stderr
  config.active_support.test_order = :random if config.active_support.respond_to?(:test_order=)
  config.eager_load = false
  config.secret_key_base = "secret"
  config.logger = Logger.new(RUBY_PLATFORM =~ /(mingw|bccwin|wince|mswin32)/i ? 'NUL:' : '/dev/null')
end

class TestEngine < Rails::Engine
end

TestApp.initialize!

TestEngine.routes.draw do
  match '/engine/abc/test' => "engine#test", :via => :post
end

TestApp.routes.draw do
  mount TestEngine => ''
  match '/test' => "test#test", :via => [:get, :put]
  match '*path.:format' => 'charcoal/cross_origin#preflight', :via => :options
  get ':controller/:action'
end

class ActionController::TestCase
  def setup
    @routes = TestApp.routes
  end
end

if ActiveSupport::VERSION::MAJOR == 4
  require "actionpack/action_caching"
end

require 'charcoal'
