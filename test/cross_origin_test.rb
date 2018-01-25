require File.expand_path('helper', File.dirname(__FILE__))

class TestCorsController < ActionController::Base
  include Charcoal::CrossOrigin

  allow_cors :test_action, :test_error_action

  class TestError < StandardError; end

  rescue_from TestError do |e|
    head :forbidden
  end

  def test_action
    head :ok
  end

  def test_error_action
    raise TestError.new
  end
end

class TestCorsControllerTest < ActionController::TestCase
  ACTIONS = {
    "success" => :test_action,
    "error"   => :test_error_action
  }

  context TestCorsController do
    context "allowing cors" do
      subject { TestCorsController.new }

      setup do
        subject.params = { :action => "test_action" }
      end

      should "allow cors" do
        assert subject.send(:cors_allowed?)
      end
    end

    context "cors callback" do
      ["success","error"].each do |response_state|
        context "with #{response_state} response" do
          context "CORS header -> Access-Control-Allow-Origin" do
            setup do
              @original, Charcoal.configuration["allow-origin"] = Charcoal.configuration["allow-origin"], "test"

              get ACTIONS[response_state]
            end

            teardown do
              Charcoal.configuration["allow-origin"] = @original
            end

            should "be the same as the configuration" do
              assert_equal "test", @response.headers["Access-Control-Allow-Origin"], @response.headers.inspect
            end
          end

          context "CORS header -> Access-Control-Allow-Credentials" do
            context "when configured with non-false value" do
              setup do
                @original, Charcoal.configuration["credentials"] = Charcoal.configuration["credentials"], true

                get ACTIONS[response_state]
              end

              teardown do
                Charcoal.configuration["credentials"] = @original
              end

              should "be present, and true" do
                assert_equal "true", @response.headers["Access-Control-Allow-Credentials"], @response.headers.inspect
              end
            end

            context "when configured with false value" do
              setup do
                @original, Charcoal.configuration["credentials"] = Charcoal.configuration["credentials"], false

                get ACTIONS[response_state]
              end

              teardown do
                Charcoal.configuration["credentials"] = @original
              end

              should "not be present" do
                assert_nil @response.headers["Access-Control-Allow-Credentials"], @response.headers.inspect
              end
            end
          end
        end
      end

      context "when Allow-Origin is a block" do
        setup do
          block = lambda do |controller|
            controller.class.name
          end

          @original, Charcoal.configuration["allow-origin"] = Charcoal.configuration["allow-origin"], block

          get :test_action
        end

        teardown do
          Charcoal.configuration["allow-origin"] = @original
        end

        should "be the same as the configuration" do
          assert_equal "TestCorsController", @response.headers["Access-Control-Allow-Origin"], @response.headers.inspect
        end
      end

      context "when Allow-Credentials is a block" do
        context "which resolves to a non-false value" do
          setup do
            block = lambda do |controller|
              true
            end

            @original, Charcoal.configuration["credentials"] = Charcoal.configuration["credentials"], block

            get :test_action
          end

          teardown do
            Charcoal.configuration["credentials"] = @original
          end

          should "be present, and true" do
            assert_equal "true", @response.headers["Access-Control-Allow-Credentials"], @response.headers.inspect
          end
        end

        context "which resolves to a false value" do
          setup do
            block = lambda do |controller|
              false
            end

            @original, Charcoal.configuration["credentials"] = Charcoal.configuration["credentials"], block

            get :test_action
          end

          teardown do
            Charcoal.configuration["credentials"] = @original
          end

          should "not be present" do
            assert_nil @response.headers["Access-Control-Allow-Credentials"], @response.headers.inspect
          end
        end
      end

      context "without any other request method" do
        setup do
          @original, Charcoal.configuration["expose-headers"] = Charcoal.configuration["expose-headers"], %w{test 123}

          get :test_action
        end

        teardown do
          Charcoal.configuration["expose-headers"] = @original
        end

        should "render action" do
          assert_equal 200, @response.status
        end

        should "set Access-Control-Expose-Headers" do
          assert_equal "test,123", @response.headers["Access-Control-Expose-Headers"], @response.headers.inspect
        end
      end
    end
  end
end
