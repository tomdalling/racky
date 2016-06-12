require 'routing/pattern'

module Routing
  class Endpoint
    attr_reader :method, :pattern, :options

    def initialize(method, pattern, options)
      @method = method.upcase
      @pattern = Pattern.from_string(pattern)
      @options = options
    end

    def lookup(env)
      return nil unless @method == env['REQUEST_METHOD'].upcase
      captures = @pattern.match(env['PATH_INFO'])
      captures ? [captures, @options] : nil
    end

    def lookup_pattern(name)
      if @options[:name] == name
        @pattern
      else
        nil
      end
    end
  end
end
