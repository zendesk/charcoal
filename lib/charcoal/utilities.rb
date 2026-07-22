require "action_controller"
require "action_dispatch"

module Charcoal::Utilities
  # OPTIONS is the preflight question, not an answer. CONNECT/TRACE/TRACK are
  # "forbidden methods" the browser won't send cross-origin.
  # See https://fetch.spec.whatwg.org/#forbidden-method
  FORBIDDEN_CORS_METHODS = %w[OPTIONS CONNECT TRACE TRACK].freeze

  # WebDAV / versioning families (PROPFIND, MKCOL, REPORT, …): recognized by
  # Rails but never sent cross-origin. These are the RFC groups ActionDispatch
  # concatenates to build HTTP_METHODS.
  WEBDAV_METHODS = [
    *ActionDispatch::Request::RFC2518,
    *ActionDispatch::Request::RFC3253,
    *ActionDispatch::Request::RFC3648,
    *ActionDispatch::Request::RFC3744,
    *ActionDispatch::Request::RFC5323,
    *ActionDispatch::Request::RFC4791
  ].freeze

  # Verbs advertised in Access-Control-Allow-Methods.
  HTTP_METHODS = (ActionDispatch::Request::HTTP_METHODS - FORBIDDEN_CORS_METHODS - WEBDAV_METHODS)
    .map { |v| v.downcase.to_sym }.freeze

  def allowed_methods_for?(protocol)
    @allowed_methods ||= {}
    return @allowed_methods[protocol] if @allowed_methods[protocol]
    @allowed_methods[protocol] = methods_allowed_for?(protocol)
  end

  private

  def methods_allowed_for?(protocol)
    HTTP_METHODS.select do |verb|
      route = find_route(request.path, request.env.merge(method: verb))

      if route
        controller = route[:controller].camelize
        controller = "#{controller}Controller".constantize

        action = route[:action] || params[:path].last.split(".").first

        instance = controller.new
        instance.request = request
        instance.response = response

        method_name = "#{protocol}_allowed"
        controller.respond_to?(method_name.to_sym) && controller.send(method_name + "?", instance, action)
      else
        false
      end
    end
  end

  def find_route(path, env)
    routes = [Rails.application.routes]

    railties = Rails.application.railties
    railties = railties.respond_to?(:all) ? railties.all : railties._all
    routes += railties.select { |tie| tie.is_a?(Rails::Engine) }.map(&:routes)

    routes.each do |route_set|
      return route_set.recognize_path(path, env)
    rescue ActionController::RoutingError
    end

    nil
  rescue ActionController::RoutingError
    nil
  end
end
