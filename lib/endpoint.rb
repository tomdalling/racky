require 'pigeon/routing'
require 'params'
require 'session'
require 'authentication'
require 'def_deps'
require 'http_cache'

class Endpoint
  MalformedResponse = Class.new(StandardError)

  include DefDeps[:page]

  def self.new(*)
    super.freeze
  end

  def self.dependencies(*args)
    include DefDeps[*args]
  end

  def call(env)
    twin = dup
    twin.instance_variable_set(:@env, env)
    twin.send(:_run)
  end

  protected

    attr_reader :env

    def run
      raise NoMethodError, "Endpoing must implement the #run method"
    end

    def params
      @params ||= Params.get(env)
    end

    def session
      @session ||= Session.get(env)
    end

    def current_user
      @current_user ||= Authentication.get(env)
    end

    def redirect(location)
      [303, { 'Location' => location }, []]
    end

    def render(template_name, args={})
      args = args.merge(current_user: current_user)
      page.render(template_name, args)
    end

    def cache(options, &block)
      options = options.merge(cache_control: current_user ? :no_cache : :public)
      HTTPCache.response(env, options, &block)
    end

  private

    def _run
      response = run

      coerced = begin
        case response
        when String then [200, {}, [response]]
        when Fixnum then [response, {}, []]
        when Hash then [200, response, []]
        when Array
          case response.map(&:class)
          when [Fixnum, String] then [response.first, {}, [response.last]]
          when [Fixnum, Hash] then response + [[]]
          when [Hash, String] then [200, response.first, [response.last]]
          when [Fixnum, Hash, String] then [response[0], response[1], [response[2]]]
          else response.size == 3 ? response : nil
          end
        end
      end

      if coerced.nil?
        raise MalformedResponse, response.inspect
      end

      coerced
    end
end
