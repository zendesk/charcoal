# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'

class Charcoal::CORSController < (defined?(ApplicationController) ? ApplicationController : ActionController::Base)
  include Charcoal::CORS

  # OPTIONS *
  def preflight
    allowed_methods = ActionController::Routing::HTTP_METHODS.select do |verb|
      begin
        if ActiveSupport::VERSION::MAJOR >= 3
          Rails.application.routes.recognize_path(request.path, request.env.merge(:method => verb))
        else
          ActionController::Routing::Routes.routes.find {|r| r.recognize(request.path, request.env.merge(:method => verb))}
        end
      rescue ActionController::RoutingError
        false
      end
    end

    set_cors_headers
    response.headers["Access-Control-Allow-Methods"] = allowed_methods.join(",").upcase
    response.headers["Access-Control-Max-Age"] = Charcoal.configuration["max-age"]
    response.headers['Access-Control-Allow-Headers'] = Charcoal.configuration["allow-headers"]

    head :ok, :content_type => "text/plain"
  end
end
