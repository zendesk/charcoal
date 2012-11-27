module Charcoal
  module ControllerFilter
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def allow(filter, &block)
        action = "allow_#{filter}"
        define_method action do |*args|
          # If we don't need 1.8 compat then ->(options = {}) instead of *args and the next line
          options = args.last.is_a?(Hash) ? args.pop : {}
          options.assert_valid_keys(:only, :except, :if, :unless)

          methods = args.map(&:to_sym)
          methods = [:all] if methods.empty?

          if options[:unless]
            directive = lambda {|c| !parse_directive(options[:unless]).call(c)}
          else
            directive = parse_directive(options[:if] || true)
          end

          methods.each do |method|
            instance_exec(method, directive, &block)
          end
        end
      end
    end

    private

    def parse_directive(directive)
      return directive if directive.respond_to?(:call)

      if directive.respond_to?(:to_sym) && method_defined?(directive.to_sym)
        lambda {|c| c.send(directive.to_sym)}
      else
        lambda {|c| directive}
      end
    end
  end
end
