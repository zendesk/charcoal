require 'bundler/setup'

ENV["RAILS_ENV"] = "test"

begin
  require 'byebug'
rescue LoadError
end

require 'minitest/autorun'

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

class ActiveSupport::TestCase
  def change_params(change)
    if Rails::VERSION::MAJOR < 5
      subject.params.replace(change)
    else
      subject.params = subject.params.to_unsafe_h.merge(change)
    end
  end
end

class ActionController::TestCase
  def setup
    @routes = TestApp.routes
  end
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6.0') && ActionPack.version < Gem::Version.new('5.0.0')
  module ActionControllerTestResponseThreadingPatch
    def recycle!
      # hack to avoid MonitorMixin double-initialize error:
      @mon_mutex_owner_object_id = nil
      @mon_mutex = nil
      initialize
    end
  end

  ActionController::TestResponse.prepend ActionControllerTestResponseThreadingPatch
else
  ActiveSupport::Deprecation.warn <<~WARN
    ActionController::TestResponse monkey patch at #{__FILE__}:#{__LINE__} will no longer be needed when Rails 4.x support is dropped.
  WARN
end


if ActiveSupport::VERSION::MAJOR >= 4
  require "action_controller/action_caching"
end

require 'charcoal'
