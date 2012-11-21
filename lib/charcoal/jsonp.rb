require 'charcoal/controller_filter'

module Charcoal
  module JSONP
    def self.included(klass)
      klass.extend(ClassMethods)
      klass.prepend_around_filter :add_jsonp_callback
    end

    module ClassMethods
      include ControllerFilter

      def jsonp_allowed
        @jsonp_allowed ||= Hash.new(lambda {|_| false})
      end

      allow :jsonp do |method, directive|
        jsonp_allowed[method.to_sym] = directive
      end

      def jsonp_allowed?(instance, action)
        jsonp_allowed[action.to_sym].try(:call, instance) ||
          (action != :all && jsonp_allowed?(instance, :all))
      end
    end

    def jsonp_allowed?
      self.class.jsonp_allowed?(self, params[:action])
    end

    def jsonp_request?
      params[:callback].present? && jsonp_allowed?
    end

    protected

    def add_jsonp_callback
      yield

      if response.status.to_s.starts_with?('200') && jsonp_request?
        response.body = "#{params[:callback]}(#{response.body})"
        response.content_type = "application/javascript"
      end
    end
  end
end
