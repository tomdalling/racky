=begin

Router API Ideas
================

 - Routes could be split up across multiple files, and combined (mounted) to
   created aggregate routers

 - Symbols in the routing DSL are used to lookup and instantiate the correct
   controller object, possibly using dry-container.

 - Middleware declarations are hoisted, meaning that they apply to all routes
   within the current router/subrouter

 - _Any_ rack-compatible app can be mounted into any router.

Example Code
------------

AUTH_ROUTES = Routing.define do
  namespace '/auth' do
    get  '/sign_in' => :sign_in_form
    post '/sign_in' => :sign_in
    post '/sign_out' => :sign_out
  end
end

ALL_ROUTES = Routing.define do
  middleware Authentication

  mount AUTH_ROUTES

  subrouter do
    middleware EnforceAuthenticated
    get  '/' => :home
  end

  mount :not_found
end

IceNine.deep_freeze(ALL_ROUTES)

=end


module R2
  ROUTING_CAPTURES_ENV_KEY = 'racky.routing_captures'

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


  class Endpoint
    attr_reader :method, :pattern, :options

    def initialize(method, pattern, next_app)
      @method = method.upcase
      @pattern = pattern
      @next_app = next_app
    end

    def call(env)
      return nil unless @method == env.fetch('REQUEST_METHOD').upcase

      captures = @pattern.match(env.fetch('PATH_INFO'))
      return nil unless captures

      next_env = env.merge(ROUTING_CAPTURES_ENV_KEY => captures) do
        |_, old_caps, new_caps|
        old_caps.merge(new_caps)
      end

      @next_app.call(next_env)
    end
  end


  class Router
    attr_reader :next_apps

    def initialize(next_apps)
      @next_apps = next_apps
    end

    def call(env)
      @next_apps.each do |app|
        response = app.call(env)
        return response if response
      end

      nil
    end
  end

  class Namespace
    attr_reader :prefix, :next_app

    def initialize(prefix, next_app)
      @prefix = prefix
      @next_app = next_app
    end

    def call(env)
      path = env.fetch('PATH_INFO')
      if path.start_with?(@prefix)
        #TODO: should the stripped prefix be added to the env anywhere?
        #      maybe under the 'SCRIPT_NAME' key?
        next_env = env.merge('PATH_INFO' => path[@prefix.length..-1])
        @next_app.call(next_env)
      else
        nil
      end
    end
  end

  class DSL
    class UnresolvedRoutingIdentifier < StandardError; end

    def initialize(app_resolver)
      @app_resolver = app_resolver
      @stack = []
    end

    def define(&definition_block)
      _push
      instance_eval(&definition_block)
      _pop
    end

    def group(&definition_block)
      _subapps << define(&definition_block)
    end

    def namespace(prefix, &definition_block)
      _push
      instance_eval(&definition_block)
      router = _pop

      mount Namespace.new(prefix, router)
    end

    def get(pattern_to_app)
      endpoint('GET', pattern_to_app)
    end

    def post(pattern_to_app)
      endpoint('POST', pattern_to_app)
    end

    def endpoint(http_method, pattern_to_app)
      pattern_to_app.each do |pattern_format, app_id|
        pattern = Pattern.from_string(pattern_format)
        final_app = resolve(app_id)
        app = _wrap_middlewares(_all_middlewares, final_app)
        mount Endpoint.new(http_method, pattern, app)
      end
    end

    def mount(app_id)
      _subapps << resolve(app_id)
    end

    def middleware(klass, *args)
      _top_middlewares << [klass, args]
    end

    def resolve(app_id)
      unless app_id.is_a?(Symbol) || app_id.is_a?(String)
        # if it's not a symbol or string, assume it's already an app object
        return app_id
      end

      result = @app_resolver[app_id]
      unless result
        raise UnresolvedRoutingIdentifier, "Can't resolve routing idenfitier: #{app_id.inspect}"
      end
      result
    end

    private

      def _push
        @stack << { subapps: [], middlewares: [] }
      end

      def _pop
        raise ArgumentError if @stack.empty?

        router = (_subapps.count == 1 ? _subapps.first : Router.new(_subapps))

        @stack.pop

        router
      end

      def _subapps
        raise ArgumentError if @stack.empty?
        @stack.last.fetch(:subapps)
      end

      def _all_middlewares
        raise ArgumentError if @stack.empty?
        @stack.flat_map{ |top| top.fetch(:middlewares) }
      end

      def _top_middlewares
        raise ArgumentError if @stack.empty?
        @stack.last.fetch(:middlewares)
      end

      def _wrap_middlewares(middlewares, final_app)
        middlewares.reverse.reduce(final_app) do |next_app, (mw_class, mw_args)|
          mw_class.new(next_app, *mw_args)
        end
      end
  end

end
