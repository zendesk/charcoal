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

      context "without any other request method" do
        setup do
          get :test_action
        end

        should "add headers" do
          assert_not_nil @response.headers["Access-Control-Allow-Origin"], @response.headers.inspect
        end

        should "render action" do
          assert_equal "noop", @response.body
        end
      end
    end
  end
end
