module Routing
  class DSL
    def initialize
      @routes = []
    end

    def make_root_router
      Router.new(@routes)
    end

    # == DSL methods below =====

    HTTP_VERBS = %w(GET HEAD POST PUT DELETE OPTIONS PATCH)
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

    def mount(router)
      @routes << router
    end

    def always(target)
      @routes << Always.new(target)
    end
  end
end