module Attrs

  module PrimaryKey
    def self.call(value)
      if value.is_a?(Integer) && value >= 0
        value
      else
        raise ArgumentError, "Invalid PrimaryKey: #{value.inspect}"
      end
    end
  end

  module ForeignKey
    def self.call(value)
      if value.is_a?(Integer) && value > 0
        value
      else
        raise ArgumentError, "Invalid ForeignKey: #{value.inspect}"
      end
    end
  end

  module MachineName
    VALID = /\A[a-zA-Z0-9_\-]+\z/

    def self.call(value)
      if value.is_a?(String) && VALID.match(value)
        value
      else
        raise ArgumentError, "Invalid MachineName: #{value.inspect}"
      end
    end
  end

  def self.type(klass)
    Proc.new do |value|
      if value.is_a?(klass)
        value
      else
        raise ArgumentError, "Not a #{klass.inspect}: #{value}"
      end
    end
  end

  def self.maybe_type(klass)
    type_block = type(klass)
    Proc.new do |value|
      if value.nil?
        nil
      else
        type_block.call(value)
      end
    end
  end
end
