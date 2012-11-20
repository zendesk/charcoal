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
          @request.stubs(:path => "/test")
          get :preflight
        end

        should "allow proper methods" do
          assert_equal "GET,PUT", @response.headers["Access-Control-Allow-Methods"], @response.headers.inspect
        end

        {
          "Access-Control-Max-Age" => "max-age",
          "Access-Control-Allow-Headers" => "allow-headers"
        }.each do |header, key|
          should "set #{header} header" do
            assert_equal Charcoal.configuration[key], @response.headers[header], @response.headers.inspect
          end
        end

        should "render text/plain response" do
          assert_equal " ", @response.body
          assert_match %r[text/plain], @response.headers["Content-Type"], @response.headers.inspect
        end
      end
    end
  end
end
