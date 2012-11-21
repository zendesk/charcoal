require File.expand_path("helper", File.dirname(__FILE__))

class TestController < ActionController::Base
  include Charcoal::CORS
  allow_cors :test

  # GET, PUT
  def test; end
end

class Charcoal::CORSControllerTest < ActionController::TestCase
  context Charcoal::CORSController do
    setup do
      @request.env["HTTPS"] = "on"
    end

    context "unrecognized path to #preflight" do
      setup do
        @request.stubs(:path => "/my_unrecognized_path")
        get :preflight
      end

      should "allow proper methods" do
        assert_equal "", @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
      end
    end

    context "OPTIONS to #preflight" do
      context "with request method = OPTIONS" do
        setup do
          @request.stubs(:path => "/test")
          get :preflight
        end

        should "allow proper methods" do
          assert_equal "GET,PUT", @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
        end

        should "set Access-Control-Allow-Headers header" do
          assert_equal Charcoal.configuration["allow-headers"].join(","), @response.headers["Access-Control-Allow-Headers"], @response.headers.inspect
        end

        should "set Access-Control-Max-Age header" do
          assert_equal Charcoal.configuration["max-age"].to_s, @response.headers["Access-Control-Max-Age"], @response.headers.inspect
        end

        should "render text/plain response" do
          assert_equal " ", @response.body
          assert_match %r[text/plain], @response.headers["Content-Type"], @response.headers.inspect
        end
      end
    end
  end
end
