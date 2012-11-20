module Charcoal
  def self.configuration
    @configuration ||= {
      "credentials" => true,
      "expose-headers" => "",
      "allow-headers" => "X-Requested-With, X-Prototype-Version",
      "max-age" => "86400",
      "allow-origin" => "*"
    }
  end

  autoload :ControllerFilter, 'charcoal/controller_filter'
  autoload :CORS, 'charcoal/cors'
  autoload :CORSController, 'charcoal/cors_controller'
  autoload :JSONP, 'charcoal/jsonp'
  # autoload :ParameterWhitelist, "charcoal/parameter_whitelist"
end

