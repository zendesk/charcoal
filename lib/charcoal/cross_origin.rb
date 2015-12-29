require 'charcoal/controller_filter'

module Charcoal
  module CrossOrigin
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.around_filter :set_cors_headers_filter, :if => :cors_allowed?
    end

    module ClassMethods
      include ControllerFilter

      def cors_allowed
        @cors_allowed ||= Hash.new(lambda {|_| false})
      end

      allow :cors do |method, directive|
        cors_allowed[method.to_sym] = directive
      end

      def cors_allowed?(instance, action)
        cors_allowed[action.to_sym].try(:call, instance) ||
          (action != :all && cors_allowed?(instance, :all))
      end
    end

    protected

    def cors_allowed?
      self.class.cors_allowed?(self, params[:action])
    end

    def set_cors_headers_filter
      yield
      set_cors_headers
    rescue
      set_cors_headers
      raise
    end

    def set_cors_headers
      headers["Access-Control-Allow-Origin"] = allowed_origin
      headers["Access-Control-Allow-Credentials"] = Charcoal.configuration["credentials"].to_s
      headers["Access-Control-Expose-Headers"] = Charcoal.configuration["expose-headers"].join(",")
    end

    def allowed_origin
      value = Charcoal.configuration["allow-origin"]
      value.respond_to?(:call) ? value.call(self) : value.to_s
    end
  end
end
