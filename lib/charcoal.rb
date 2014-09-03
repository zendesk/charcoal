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
  autoload :CrossOrigin, 'charcoal/cross_origin'
  autoload :JSONP, 'charcoal/jsonp'

  autoload :CrossOriginController, 'charcoal/cross_origin_controller'
end

