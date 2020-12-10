module HasuraRecord
  module HasuraHelpers
    module ClassDelegate

      def self.included(base)
        base.extend(self)
      end

      def delegate_class(*methods, to: nil, prefix: nil, allow_nil: nil)
        unless to
          raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, to: :greeter)."
        end
    
        if prefix == true && /^[^a-z_]/.match?(to)
          raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
        end
    
        method_prefix =        if prefix
            "#{prefix == true ? to : prefix}_"
          else
            ""
          end
    
        location = caller_locations(1, 1).first
        file, line = location.path, location.lineno
    
        to = to.to_s
        to = "self.#{to}"
    
        methods.map do |method|
          # Attribute writer methods only accept one argument. Makes sure []=
          # methods still accept two arguments.
          definition = /[^\]]=$/.match?(method) ? "arg" : "*args, &block"

          if allow_nil
            method_def = [
              "def self.#{method_prefix}#{method}(#{definition})",
              "_ = #{to}",
              "if !_.nil? || nil.respond_to?(:#{method})",
              "  _.#{method}(#{definition})",
              "end",
            "end"
            ].join ";"
          else
            exception = %(raise DelegationError, "#{self}##{method_prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
    
            method_def = [
              "def self.#{method_prefix}#{method}(#{definition})",
              " _ = #{to}",
              "  _.#{method}(#{definition})",
              "rescue NoMethodError => e",
              "  if _.nil? && e.name == :#{method}",
              "    #{exception}",
              "  else",
              "    raise",
              "  end",
              "end"
            ].join ";"
          end
    
          module_eval(method_def, file, line)
        end
      end
    end
  end
end