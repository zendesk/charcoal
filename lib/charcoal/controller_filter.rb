require "active_support/core_ext/array/extract_options"

module Charcoal
  module ControllerFilter
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def allow(filter, &block)
        action = "allow_#{filter}"
        define_method action do |*args|
          options = args.extract_options!
          options.assert_valid_keys(:only, :except, :if, :unless)

          methods = args.map(&:to_sym)
          methods = [:all] if methods.empty?

          if_conditions = Array(options[:if]).map { |condition| parse_directive(condition) }
          unless_conditions = Array(options[:unless]).map { |condition| parse_directive(condition) }
          directive = lambda do |controller|
            if_conditions.all? { |condition| condition.call(controller) } &&
              unless_conditions.none? { |condition| condition.call(controller) }
          end

          methods.each do |method|
            instance_exec(method, directive, &block)
          end
        end
      end
    end

    private

    def parse_directive(directive)
      case directive
      when Symbol, String
        lambda { |controller| controller.send(directive.to_sym) }
      when Proc
        # Like Rails callbacks, evaluate blocks in the controller's context.
        if directive.arity > 0
          lambda { |controller| controller.instance_exec(controller, &directive) }
        else
          lambda { |controller| controller.instance_exec(&directive) }
        end
      else
        directive.respond_to?(:call) ? directive : lambda { |_| directive }
      end
    end
  end
end
