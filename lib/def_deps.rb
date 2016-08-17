module DefDeps
  InvalidDependency = Class.new(StandardError)
  MissingDependency = Class.new(StandardError)

  def self.[](*deps_input)
    deps = standardize_deps(deps_input)
    Module.new do
      const_set(:DECLARED_DEPENDENCIES, deps)
      deps.each { |attr, _| attr_reader(attr) }

      def initialize(given_deps)
        self.class::DECLARED_DEPENDENCIES.each do |attr, _|
          dep = given_deps[attr]
          if dep.nil?
            raise MissingDependency, "Missing dependency: #{attr.inspect}"
          end
          instance_variable_set("@#{attr}", dep)
        end
      end
    end
  end

  def self.standardize_deps(deps_input)
    deps_input.map do |dep|
      case dep
      when Hash then dep.map{ |k, v| [k.to_sym, v.to_s] }.to_h
      when Symbol then { dep => dep.to_s }
      when String then { dep.to_sym => dep }
      else raise InvalidDependency, "Invalid dependency: #{dep.inspect}"
      end
    end.reduce({}, :merge!)
  end
end
