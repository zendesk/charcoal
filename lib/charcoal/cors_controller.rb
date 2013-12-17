# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'

require 'charcoal/cors_helper'

class Charcoal::CORSController < ActionController::Base
  include Charcoal::CORS

  allow_cors :all

  # OPTIONS *
  def preflight
    if allowed_methods.any?
      set_cors_headers
      headers["Access-Control-Allow-Methods"] = allowed_methods.join(",").upcase
      headers["Access-Control-Max-Age"] = Charcoal.configuration["max-age"].to_s
      headers['Access-Control-Allow-Headers'] = Charcoal.configuration["allow-headers"].join(",")
    end

    head :ok, :content_type => "text/plain"
  end

  private

  def allowed_methods
    @allowed_methods ||= ActionController::Routing::HTTP_METHODS.select do |verb|
      next if verb == :options

      begin
        route = if ActiveSupport::VERSION::MAJOR >= 3
          Rails.application.routes.recognize_path(request.path, request.env.merge(:method => verb))
        else
          ActionController::Routing::Routes.routes.find {|r| r.recognize(request.path, request.env.merge(:method => verb))}
        end

        if route
          route = route.requirements if ActiveSupport::VERSION::MAJOR < 3

          controller = route[:controller].camelize
          controller = "#{controller}Controller".constantize

          action = route[:action] || params[:path].last.split(".").first

          instance = controller.new
          instance.request = request
          instance.response = response

          controller.respond_to?(:cors_allowed) && controller.cors_allowed?(instance, action)
        else
          false
        end
      rescue ActionController::RoutingError
        false
      end
    end
  end
end
