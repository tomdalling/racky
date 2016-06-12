require 'routing/pattern'

module Routing
  class Endpoint
    def initialize(method, pattern, target)
      @method = method.upcase
      @pattern = Pattern.new(pattern)
      @target = target
    end

    def lookup(env)
      return nil unless @method == env['REQUEST_METHOD'].upcase
      captures = @pattern.match(env['PATH_INFO'])
      captures ? [captures, @target] : nil
    end
  end
end
