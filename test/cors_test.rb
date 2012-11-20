require File.expand_path('helper', File.dirname(__FILE__))

class TestCorsController < ActionController::Base
  include Charcoal::CORS

  def test_action
    render :text => "noop"
  end
end

class TestCorsControllerTest < ActionController::TestCase
  context TestCorsController do
    context "allowing cors" do
      subject { TestCorsController.new }

      setup do
        TestCorsController.allow_cors
        subject.params = { :action => "test_action" }
      end

      should "allow cors" do
        assert subject.cors_allowed?
      end
    end

    context "cors callback" do
      setup do
        TestCorsController.allow_cors
      end

      {
        "Access-Control-Allow-Origin" => "allow-origin",
        "Access-Control-Allow-Credentials" => "credentials",
        "Access-Control-Expose-Headers" => "expose-headers"
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

      context "without any other request method" do
        setup { get :test_action }

        should "render action" do
          assert_equal "noop", @response.body
        end
      end
    end
  end
end
