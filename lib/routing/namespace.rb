require 'routing/pattern'

module Routing
  class Namespace
    attr_reader :prefix, :subrouter

    def initialize(prefix, subrouter)
      @prefix = prefix
      @subrouter = subrouter
    end

    def lookup(env)
      path = env['PATH_INFO']
      if path.start_with?(@prefix)
        @subrouter.lookup(env.merge('PATH_INFO' => path[@prefix.length..-1]))
      else
        nil
      end
    end

    def lookup_pattern(name)
      pattern = @subrouter.lookup_pattern(name)
      pattern && Pattern.new([@prefix] + pattern.parts)
    end
  end
end
