# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'

require 'charcoal/cors_helper'

class Charcoal::CORSController < ActionController::Base
  include Charcoal::CORS

  allow_cors :all
  skip_after_filter :set_cors_headers

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
    @allowed_methods ||= ActionDispatch::Routing::HTTP_METHODS.select do |verb|
      next if verb == :options

      route = find_route(request.path, request.env.merge(:method => verb))

      if route
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
    end
  end

  def find_route(path, env)
    if ActiveSupport::VERSION::MAJOR >= 3
      routes = [Rails.application.routes]

      routes += Rails.application.railties.select {|tie|
        tie.is_a?(Rails::Engine)
      }.map(&:routes)

      routes.each do |route_set|
        begin
          return route_set.recognize_path(path, env)
        rescue ActionController::RoutingError
        end
      end

      nil
    else
      ActionController::Routing::Routes.routes.find {|r| r.recognize(path, env)}.try(:requirements)
    end
  rescue ActionController::RoutingError
    nil
  end
end
