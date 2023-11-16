require File.expand_path("helper", File.dirname(__FILE__))
require "charcoal/utilities"

class TestCorsController < ActionController::Base
  include Charcoal::CrossOrigin
  include Charcoal::Utilities

  allow_cors :test

  def test
    render json: {
      cors: allowed_methods_for?(:cors),
      others: allowed_methods_for?(:others)
    }
  end
end

class TestCorsControllerTest < ActionController::TestCase
  context TestCorsController do
    context "#allowed_methods_for?" do
      subject { TestCorsController.new }

      setup do
        subject.params = {action: "test"}
      end

      should "return the allowed methods" do
        get :test

        parsed_response = JSON.parse(response.body)

        refute parsed_response["cors"].empty?
        assert parsed_response["others"].empty?
      end
    end
  end
end
