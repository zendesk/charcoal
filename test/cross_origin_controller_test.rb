require File.expand_path("helper", File.dirname(__FILE__))

class TestController < ActionController::Base
  include Charcoal::CrossOrigin

  allow_cors :test

  # GET, PUT
  def test
  end
end

class EngineController < ActionController::Base
  include Charcoal::CrossOrigin

  allow_cors :test

  # POST
  def test
  end
end

class Charcoal::CrossOriginControllerTest < ActionController::TestCase
  context Charcoal::CrossOriginController do
    setup do
      @request.env["HTTPS"] = "on"
    end

    context "unrecognized path to #preflight" do
      setup do
        @request.path = "/my_unrecognized_path"
        get :preflight
      end

      should "not set allow-origin" do
        assert_nil @response.headers["Access-Control-Allow-Origin"], @response.headers.inspect
      end

      should "allow proper methods" do
        assert_nil @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
      end
    end

    context "OPTIONS to #preflight" do
      context "with request method = OPTIONS" do
        setup do
          @request.path = "/test"
          get :preflight
        end

        should "allow proper methods" do
          allowed = ["GET", "HEAD", "PUT"]
          assert_equal allowed.join(","), @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
        end

        should "set Access-Control-Allow-Headers header" do
          assert_equal Charcoal.configuration["allow-headers"].join(","), @response.headers["Access-Control-Allow-Headers"], @response.headers.inspect
        end

        should "set Access-Control-Max-Age header" do
          assert_equal Charcoal.configuration["max-age"].to_s, @response.headers["Access-Control-Max-Age"], @response.headers.inspect
        end

        should "render text/plain response" do
          assert @response.body.blank?
          assert_match %r{text/plain}, @response.headers["Content-Type"], @response.headers.inspect
        end
      end
    end

    context "engine request path" do
      setup do
        @request.path = "/engine/abc/test"
        get :preflight
      end

      should "allow proper methods" do
        assert_equal "POST", @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
      end

      should "set Access-Control-Allow-Headers header" do
        assert_equal Charcoal.configuration["allow-headers"].join(","), @response.headers["Access-Control-Allow-Headers"], @response.headers.inspect
      end

      should "set Access-Control-Max-Age header" do
        assert_equal Charcoal.configuration["max-age"].to_s, @response.headers["Access-Control-Max-Age"], @response.headers.inspect
      end

      should "render text/plain response" do
        assert @response.body.blank?
        assert_match %r{text/plain}, @response.headers["Content-Type"], @response.headers.inspect
      end
    end
  end
end
