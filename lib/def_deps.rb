module DefDeps
  InvalidDependency = Class.new(StandardError)
  MissingDependency = Class.new(StandardError)

  def self.[](*deps_input)
    declared_deps = standardize_deps(deps_input)
    Module.new do |mod|
      const_set(:DECLARED_DEPENDENCIES, declared_deps)
      declared_deps.each { |attr, _| attr_reader(attr) }

      # Accepts a single hash of dependencies
      define_method(:initialize) do |given_deps|
        superclass = self.class.ancestors.drop_while{ |c| c != mod }[1]
        if superclass.const_defined?(:DECLARED_DEPENDENCIES)
          super(given_deps)
        else
          super()
        end

        declared_deps.each do |attr, _|
          dep = given_deps[attr]
          if nil == dep
            raise MissingDependency, "Missing dependency for #{self.class}: #{attr.inspect}"
          end
          instance_variable_set("@#{attr}", dep)
        end
      end

      # Gives the module a nicer name, something like Whatever::DefDepsMixin
      # instead of #<Module 0xA3B4C5939393>
      def self.included(descendant)
        descendant.const_set(:DefDepsMixin, self)
      end
    end
  end

  def self.get(klass)
    klass
      .ancestors
      .reverse
      .select { |k| k.const_defined?(:DECLARED_DEPENDENCIES, false)}
      .map{ |k| k::DECLARED_DEPENDENCIES }
      .reduce({}, &:merge!)
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
