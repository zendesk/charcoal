module Charcoal
  def self.configuration
    @configuration ||= {
      "credentials" => true,
      "expose-headers" => %w{},
      "allow-headers" => %w{X-Requested-With X-Prototype-Version},
      "max-age" => 86400,
      "allow-origin" => "*"
    }
  end

  autoload :ControllerFilter, 'charcoal/controller_filter'
  autoload :CORS, 'charcoal/cors'
  autoload :JSONP, 'charcoal/jsonp'

  autoload :CORSController, 'charcoal/cors_controller'
  # autoload :ParameterWhitelist, "charcoal/parameter_whitelist"
end

