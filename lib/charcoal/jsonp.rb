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
    end

    def jsonp_allowed?
      self.class.jsonp_allowed[params[:action].try(:to_sym)].call(self)
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
