require 'action_controller'

module Charcoal::Utilities
  Routing = defined?(ActionDispatch) ? ActionDispatch::Routing : ActionController::Routing

  def allowed_methods_for?(protocol)
    @allowed_methods ||= {}
    return @allowed_methods[protocol] if @allowed_methods[protocol]
    @allowed_methods[protocol] = methods_allowed_for?(protocol)
  end

  private

  def methods_allowed_for?(protocol)
    Routing::HTTP_METHODS.select do |verb|
      next if verb == :options

      route = find_route(request.path, request.env.merge(:method => verb))

      if route
        controller = route[:controller].camelize
        controller = "#{controller}Controller".constantize

        action = route[:action] || params[:path].last.split(".").first

        instance = controller.new
        instance.request = request
        instance.response = response

        method_name = "#{protocol}_allowed"
        controller.respond_to?(method_name.to_sym) && controller.send(method_name + '?', instance, action)
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
