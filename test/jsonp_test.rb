require File.expand_path('helper', File.dirname(__FILE__))

class JSONPControllerTester < ActionController::Base
  include Charcoal::JSONP

  caches_action :test
  allow_jsonp :test

  def test
    render :json => { :key => :value }
  end
end

class JSONPTest < ActionController::TestCase
  tests JSONPControllerTester

  context JSONPControllerTester do
    context "with caching" do
      setup do
        @caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
        @cache_store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
      end

      teardown do
        ActionController::Base.perform_caching = @caching
        ActionController::Base.cache_store = @cache_store
      end

      context "a GET to :test" do
        setup do
          if Rails::VERSION::MAJOR < 5
            get :test, :callback => "hello"
          else
            get :test, :params => { :callback => "hello" }
          end
        end

        should "return a proper response" do
          assert_match /hello\(.*\)/, @response.body
        end

        should "return a proper response type" do
          assert_equal "application/javascript", @response.content_type
        end

        context "a second call" do
          setup do
            get :test, :callback => "hello"
          end

          should "properly cache the response" do
            assert_match /hello\(.*\)/, @response.body
          end

          should "properly cache the response type" do
            assert_equal "application/javascript", @response.content_type
          end
        end
      end
    end
  end

  context Charcoal::JSONP do
    subject { JSONPControllerTester.new }

    setup do
      subject.params = {}
    end

    context "jsonp callback" do
      setup do
        @response = '{"test": 123}'
        @content_type = "application/json"

        subject.response = (defined?(ActionDispatch) ? ActionDispatch : ActionController)::Response.new
        subject.response.body = @response
        subject.response.status = '200 OK'
        subject.response.content_type = @content_type
      end

      context "with params" do
        setup do
          subject.params.replace(:callback => "callback", :action => "test")
          subject.send(:add_jsonp_callback) {}
        end

        should "add jsonp if there is a callback" do
          assert_equal "callback(#{@response})", subject.response.body
        end

        should "change content-type" do
          assert_equal "application/javascript", subject.response.content_type
        end
      end

      context "without params" do
        setup { subject.send(:add_jsonp_callback) {} }

        should "not add jsonp callback" do
          assert_equal @response, subject.response.body
        end

        should "not change content-type" do
          assert_equal @content_type, subject.response.content_type
        end
      end
    end
  end
end
