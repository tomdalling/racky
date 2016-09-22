module Pigeon
  class Struct
    def self.define(&block)
      define_from(nil, &block)
    end

    def self.define_from(struct_class, &block)
      existing_defs = struct_class ? struct_class::ATTRIBUTE_DEFINITIONS.dup : {}

      Class.new(Pigeon::Struct) do
        const_set(:ATTRIBUTE_DEFINITIONS, existing_defs)
        instance_eval(&block)
        self::ATTRIBUTE_DEFINITIONS.freeze
        self::ATTRIBUTE_DEFINITIONS.keys.each { |attr| attr_accessor attr }
      end
    end

    def self.def_attr(attr, options={})
      self::ATTRIBUTE_DEFINITIONS.merge!(attr => AttributeOptions.new(options)) do
        raise ArgumentError, "Attribute #{attr.inspect} already defined"
      end
    end

    def initialize(value_hash)
      self.class::ATTRIBUTE_DEFINITIONS.each do |attr, options|
        assign_attr!(attr, options, value_hash)
      end

      extraneous = value_hash.keys - self.class::ATTRIBUTE_DEFINITIONS.keys
      unless extraneous.empty?
        raise ArgumentError, "Extraneous attributes for #{self.class.name}: #{extraneous.map(&:inspect).join(', ')}"
      end

      @hash = self.class.hash ^ to_h.hash

      freeze
    end

    def with(changed_attrs)
      self.class.new(to_h.merge(changed_attrs))
    end

    def to_h
      self.class::ATTRIBUTE_DEFINITIONS
        .map { |attr, _| [attr, send(attr)] }
        .to_h
    end

    def [](attr)
      send(attr)
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      self.class == other.class && self.to_h == other.to_h
    end

    def hash
      @hash
    end

    private

      def assign_attr!(attr, options, value_hash)
        value = case
                when value_hash.has_key?(attr)
                  options.coercer.call(value_hash[attr])
                when options.default != AttributeOptions::NotSpecified
                  options.default
                else
                  raise ArgumentError, "Missing attribute #{attr.inspect} for #{self.class.name}"
                end

        instance_variable_set("@#{attr}", value)
      end

      class AttributeOptions
        attr_reader :default, :coercer

        def initialize(options)
          @default = options.fetch(:default, NotSpecified)
          @coercer = options.fetch(:coercer, IdentityCoercer)
          freeze
        end

        NotSpecified = Class.new(Object)
        IdentityCoercer = ->(x){ x }
      end
  end
end

