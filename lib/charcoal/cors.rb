require 'charcoal/controller_filter'

module Charcoal
  module CORS
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.after_filter :set_cors_headers, :if => :cors_allowed?
    end

    module ClassMethods
      include ControllerFilter

      def cors_allowed
        @cors_allowed ||= Hash.new(lambda {|_| false})
      end

      allow :cors do |method, directive|
        cors_allowed[method.to_sym] = directive
      end
    end

    def cors_allowed?
      self.class.cors_allowed[params[:action].to_sym].call(self)
    end

    protected

    def set_cors_headers
      headers["Access-Control-Allow-Origin"] = Charcoal.configuration["allow-origin"]
      headers["Access-Control-Allow-Credentials"] = Charcoal.configuration["credentials"]
      headers["Access-Control-Expose-Headers"] = Charcoal.configuration["expose-headers"].join(",")
    end
  end
end
