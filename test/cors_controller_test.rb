require File.expand_path("helper", File.dirname(__FILE__))

class TestController < ActionController::Base
  # GET, PUT
  def test; end
end

class Charcoal::CORSControllerTest < ActionController::TestCase
  context Charcoal::CORSController do
    setup do
      @request.env["HTTPS"] = "on"
    end

    context "OPTIONS to #preflight" do
      context "with request method = OPTIONS" do
        setup do
          @request.path = "/test"

          get :preflight
        end

        should "allow proper methods" do
          assert_equal "GET,PUT", @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
        end

        should "render text/plain response" do
          assert_equal " ", @response.body
          assert @response.content_type.include?("text/plain")
        end
      end
    end
  end
end
