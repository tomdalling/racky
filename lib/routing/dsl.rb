module Routing
  class DSL
    HTTP_VERBS = %w(GET HEAD POST PUT DELETE OPTIONS PATCH)

    def initialize
      @routes = []
    end

    HTTP_VERBS.each do |verb|
      define_method(verb.downcase) do |*args|
        route(verb, *args)
      end
    end
    alias_method :dele, :delete
    alias_method :opts, :options
    alias_method :ptch, :patch

    def route(method, path, target)
      @routes << Endpoint.new(method, path, target)
    end

    def namespace(prefix)
      old_routes = @routes
      @routes = []
      yield
      ns_routes = @routes
      @routes = old_routes

      @routes << Namespace.new(prefix, Router.new(ns_routes))
    end

    def make_root_router
      Router.new(@routes)
    end
  end
end
