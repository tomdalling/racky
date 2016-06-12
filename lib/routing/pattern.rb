module Routing
  class Pattern
    attr_reader :parts, :regex

    def initialize(parts)
      @parts = parts
      @regex = self.class.regex(@parts)
    end

    def self.from_string(pattern)
      new(split(pattern))
    end

    def match(path)
      result = @regex.match(path)
      if result
        result.names
          .map { |name| [name.to_sym, result[name]] }
          .to_h
      else
        nil
      end
    end

    def construct_path(vars)
      self.class.construct_path(@parts, vars)
    end

    TOKEN_REGEX = /:[a-zA-Z_0-9]+/
    def self.split(str)
      str = str.dup
      result = []

      loop do
        m = TOKEN_REGEX.match(str)
        if m
          range = m.begin(0)...m.end(0)
          result << str[0...range.min] unless range.min == 0
          result << str[range][1..-1].to_sym
          str[0..range.max] = ''
        else
          result << str unless str.empty?
          break
        end
      end

      result
    end

    def self.regex(parts)
      regex_parts = parts.map do |p|
        if p.is_a?(String)
          Regexp.escape(p)
        else
          # named capture that matches anything except a forward slash
          "(?<#{p}>[^/]+)"
        end
      end

      Regexp.new('\A' + regex_parts.join + '\z')
    end

    def self.construct_path(parts, vars)
      parts
        .map { |p| p.is_a?(String) ? p : vars.fetch(p) }
        .join
    end
  end
end
