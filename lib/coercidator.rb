module Coercidator
  class Failure
    attr_reader :schema, :value, :type, :message, :path

    def initialize(schema, value, type, message=nil, path=[])
      @schema = schema
      @value = value
      @type = type
      @message = message || "Schema #{schema} failed to coercidate #{value.inspect} with failure type #{type.inspect}"
      @path = path
    end

    def with_extended_path(key)
      self.class.new(
        @schema,
        @value,
        @type,
        @message,
        [key] + @path,
      )
    end
  end

  class Result
    attr_reader :value, :failures

    def self.failure(*args)
      new(nil, [Failure.new(*args)])
    end

    def initialize(value, failures=[])
      @value = value
      @failures = failures
    end

    def merge!(result, key=nil)
      if result.failures.empty?
        @value = yield(@value, result.value)
      else
        @failures.concat(
          if key
            result.failures.map { |f| f.with_extended_path(key) }
          else
            result.failures
          end
        )
      end
    end
  end

  class Compiler
    class Error < StandardError; end

    def initialize(schema_registry)
      @schema_registry = schema_registry
    end

    def compile(schema)
      case schema
      when Hash then compile_hash(schema)
      else
        @schema_registry.fetch(schema) do
          raise Error, "No schema in registry for #{schema.inspect}"
        end
      end
    end

    def compile_hash(hash)
      HashSchema.new(
        hash
          .map{ |k, v| [k, compile(v)] }
          .to_h
      )
    end
  end

  module FailureExplainer
    def self.call(failures)
      failures
        .map(&method(:explain))
        .join("\n\n")
    end

    def self.explain(failure)
      <<~EOS.strip
        Failure: #{failure.message}
          Value: #{failure.value.inspect}
          Path: #{failure.path.inspect}
          Schema: #{failure.schema}
          Failure Type: #{failure.type.inspect}
      EOS
    end
  end

  module BoolSchema
    TRUTHY_VALUES = %w(1 true yes)
    FALSEY_VALUES = %w(0 false no) + [nil]

    def self.coercidate(value)
      v = value.is_a?(String) ? value.downcase : value

      case
      when TRUTHY_VALUES.include?(v) then Result.new(true)
      when FALSEY_VALUES.include?(v) then Result.new(false)
      else Result.failure(self, value, :invalid_bool)
      end
    end
  end

  module StringSchema
    def self.coercidate(value)
      if value.is_a?(String)
        Result.new(value)
      else
        Result.failure(self, value, :not_a_string)
      end
    end
  end

  module TimeSchema
    def self.coercidate(value)
      Result.new(Time.iso8601(value))
    rescue ArgumentError
      Result.failure(self, value, :invalid_iso8601)
    end
  end

  class HashSchema
    attr_reader :attr_schemas

    def initialize(attr_schemas)
      @attr_schemas = attr_schemas
    end

    def coercidate(value)
      unless value.is_a?(Hash)
        return Result.failure(self, value, :not_a_hash)
      end

      result = Result.new({})

      @attr_schemas.each do |key, subschema|
        subvalue = lookup(value, key)
        result.merge!(subschema.coercidate(subvalue), key) do |result_hash, coercidated_subvalue|
          result_hash[key] = coercidated_subvalue
          result_hash
        end
      end

      result
    end

    def lookup(hash, key)
      if hash.has_key?(key)
        hash[key]
      elsif key.is_a?(Symbol)
        hash[key.to_s]
      else
        nil
      end
    end
  end
end

