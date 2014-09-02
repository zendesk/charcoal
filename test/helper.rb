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

if ActiveSupport::VERSION::MAJOR >= 3
  require "action_controller/railtie"
  require "rails/test_unit/railtie"

  class TestApp < Rails::Application
    config.active_support.deprecation = :stderr
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
    match '*path.:format' => 'charcoal/C_O_R_S#preflight', :via => :options
    get ':controller/:action'
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
    map.connect "*path.:format", :conditions => { :method => :options }, :action => "preflight", :controller => "CORS", :namespace => "charcoal/"
    map.connect ':controller/:action'
  end

  ActionDispatch = ActionController
end

if ActiveSupport::VERSION::MAJOR >= 4
  require "actionpack/action_caching"
end

require 'charcoal'
