require "bundler/setup"

ENV["RAILS_ENV"] = "test"

begin
  require "byebug"
rescue LoadError
end

require "minitest/autorun"

require "shoulda"
require "active_support/version"

require "action_controller/railtie"
require "rails/test_unit/railtie"

class TestApp < Rails::Application
  config.active_support.deprecation = :stderr
  config.active_support.to_time_preserves_timezone = :zone
  config.active_support.test_order = :random if config.active_support.respond_to?(:test_order=)
  config.eager_load = false
  config.secret_key_base = "secret"
  config.logger = Logger.new(File::NULL)
end

class TestEngine < Rails::Engine
end

TestApp.initialize!

TestEngine.routes.draw do
  match "/engine/abc/test" => "engine#test", :via => :post
end

TestApp.routes.draw do
  mount TestEngine => ""
  match "/test" => "test#test", :via => [:get, :put]
  match "*path.:format" => "charcoal/cross_origin#preflight", :via => :options
  get "test_controller/test_action", to: "test_controller#test_action"
  get "test_cors/test_action", to: "test_cors#test_action"
  get "test_cors/test", to: "test_cors#test"
  get "test_cors/test_error_action", to: "test_cors#test_error_action"
  get "jsonp_controller_tester/test", to: "jsonp_controller_tester#test"
  get "charcoal/cross_origin/preflight", to: "charcoal/cross_origin#preflight"
end

class ActiveSupport::TestCase
  def change_params(change)
    subject.params = subject.params.to_unsafe_h.merge(change)
  end
end

class ActionController::TestCase
  def setup
    @routes = TestApp.routes
  end
end

require "charcoal"
