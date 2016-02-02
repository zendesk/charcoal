# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'

class Charcoal::CrossOriginController < ActionController::Base
  include Charcoal::CrossOrigin

  Routing = defined?(ActionDispatch) ? ActionDispatch::Routing : ActionController::Routing

  allow_cors :all
  if respond_to?(:skip_around_action)
    skip_around_action :set_cors_headers_filter
  else
    skip_around_filter :set_cors_headers_filter
  end

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
    @allowed_methods ||= Routing::HTTP_METHODS.select do |verb|
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
    routes = [Rails.application.routes]

    railties = Rails.application.railties
    railties = railties.respond_to?(:all) ? railties.all : railties._all
    routes += railties.select {|tie| tie.is_a?(Rails::Engine)}.map(&:routes)

    routes.each do |route_set|
      begin
        return route_set.recognize_path(path, env)
      rescue ActionController::RoutingError
      end
    end

    nil
  rescue ActionController::RoutingError
    nil
  end
end
