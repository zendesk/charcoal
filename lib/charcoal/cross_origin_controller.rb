# This controller handles CORS preflight requests
# See https://developer.mozilla.org/En/HTTP_access_control for documentation

require 'action_controller'
require 'active_support/version'
require 'charcoal/utilities'

class Charcoal::CrossOriginController < ActionController::Base
  include Charcoal::CrossOrigin
  include Charcoal::Utilities

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
    allowed_methods_for?(:cors)
  end
end
