# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation
class Charcoal::CORSController < (defined?(ApplicationController) ? ApplicationController : ActionController::Base)
  include Charcoal::CORS

  # OPTIONS *
  def preflight
    allowed_methods = ActionController::Routing::HTTP_METHODS.select do |verb|
      begin
        Rails.application.routes.recognize_path(request.path, request.env.merge(:method => verb))

        # Rails 2
        # ActionController::Routing::Routes.routes.find {|r| r.recognize(request.path, request.env.merge(:method => verb))}
      rescue
        false
      end
    end

    set_cors_headers
    response.headers["Access-Control-Allow-Methods"] = allowed_methods.join(",").upcase

    head :ok, :content_type => 'text/plain'
  end
end
