require File.expand_path('helper', File.dirname(__FILE__))

class TestCorsController < ActionController::Base
  include Charcoal::CORS

  allow_cors :test_action

  def test_action
    render :text => "noop"
  end
end

class TestCorsControllerTest < ActionController::TestCase
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
      {
        "Access-Control-Allow-Origin" => "allow-origin",
        "Access-Control-Allow-Credentials" => "credentials",
      }.each do |header, key|
        context "CORS header -> #{header}" do
          setup do
            @original, Charcoal.configuration[key] = Charcoal.configuration[key], "test"

            get :test_action
          end

          teardown do
            Charcoal.configuration[key] = @original
          end

          should "be the same as the configuration" do
            assert_equal "test", @response.headers[header], @response.headers.inspect
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

      context "without any other request method" do
        setup do
          @original, Charcoal.configuration["expose-headers"] = Charcoal.configuration["expose-headers"], %w{test 123}

          get :test_action
        end

        teardown do
          Charcoal.configuration["expose-headers"] = @original
        end

        should "render action" do
          assert_equal "noop", @response.body
        end

        should "set Access-Control-Expose-Headers" do
          assert_equal "test,123", @response.headers["Access-Control-Expose-Headers"], @response.headers.inspect
        end
      end
    end
  end
end
