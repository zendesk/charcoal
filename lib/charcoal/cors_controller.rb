# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'

require 'charcoal/cors_helper'

class Charcoal::CORSController < ActionController::Base
  include Charcoal::CORS

  # OPTIONS *
  def preflight
    allowed_methods = ActionController::Routing::HTTP_METHODS.select do |verb|
      begin
        route = if ActiveSupport::VERSION::MAJOR >= 3
          Rails.application.routes.recognize(request.path, request.env.merge(:method => verb))
        else
          ActionController::Routing::Routes.routes.find {|r| r.recognize(request.path, request.env.merge(:method => verb))}
        end

        if route
          controller = route.send(:requirement_for, :controller).camelize
          controller = "#{controller}Controller".constantize

          action = route.send(:requirement_for, :action) || params[:path].last.split(".").first

          controller.respond_to?(:cors_allowed) && controller.cors_allowed?(action)
        else
          false
        end
      rescue ActionController::RoutingError
        false
      end
    end

    if allowed_methods.any?
      set_cors_headers
      headers["Access-Control-Allow-Methods"] = allowed_methods.join(",").upcase
      headers["Access-Control-Max-Age"] = Charcoal.configuration["max-age"].to_s
      headers['Access-Control-Allow-Headers'] = Charcoal.configuration["allow-headers"].join(",")
    end

    head :ok, :content_type => "text/plain"
  end
end
