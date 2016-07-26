require 'test_helper'
require 'pigeon/routing'
require 'ice_nine'

module PigeonRoutingTests
  class PatternTest < Test
    def test_split
      {
        ':foo:bar' => [:foo, :bar],
        '/foo/:id.:format' => ['/foo/', :id, '.', :format],
      }.each do |input, output|
        expect(Pigeon::Routing::Pattern.split(input)) == output
      end
    end

    def test_regex
      {
        [:foo, :bar] => %r{\A(?<foo>[^/]+)(?<bar>[^/]+)\z},
        ['/foo/', :id, '.', :format] => %r{\A/foo/(?<id>[^/]+)\.(?<format>[^/]+)\z},
      }.each do |input, output|
        expect(Pigeon::Routing::Pattern.regex(input)) == output
      end
    end

    def test_construct_path
      parts = ['/foo/', :id, '.', :format]
      vars = { id: 4, format: 'html' }
      expect(Pigeon::Routing::Pattern.construct_path(parts, vars)) == '/foo/4.html'
    end

    def test_object
      p = Pigeon::Routing::Pattern.from_string('/foo/:id.:format')
      expect(p.match('/hello')) == nil
      expect(p.match('/foo/3.json')) == { id: '3', format: 'json' }
      expect(p.construct_path(id: 123, format: 'png')) == '/foo/123.png'
    end
  end

  class EndpointTest < Test
    def setup
      pattern = Pigeon::Routing::Pattern.from_string('/foo/:id.:format')
      next_app = proc do |env|
        @received_env = env
        [200, {'Header' => 'blah'}, ['Okie Dokie']]
      end
      @endpoint = Pigeon::Routing::Endpoint.new('GET', pattern, next_app)
    end

    def teardown
      @endpoint = nil
      @received_env = nil
    end

    def test_match
      response = @endpoint.call(Request['GET /foo/3.json'])
      expect(response) == [200, {'Header' => 'blah'}, ['Okie Dokie']]
      expect(@received_env) == {
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/foo/3.json',
        Pigeon::Routing::CAPTURES_ENV_KEY => {
          id: '3',
          format: 'json',
        }
      }
    end

    def test_mismatched_http_method
      response = @endpoint.call(Request['POST /foo/3.json'])
      expect(response).nil?
      expect(@received_env).nil?
    end

    def test_mismatched_path
      response = @endpoint.call(Request['GET /foo/wrong/3.json'])
      expect(response).nil?
      expect(@received_env).nil?
    end
  end

  class RouterTest < Test
    def test_routing
      did_run = []
      app_1 = proc { |env| did_run << :app_1; nil }
      app_2 = proc { |env| did_run << :app_2; "Got #{env['PATH_INFO']}" }
      app_3 = proc { |env| did_run << :app_3; nil }
      router = Pigeon::Routing::Router.new([app_1, app_2, app_3])

      response = router.call(Request['GET /whatever'])
      expect(response) == 'Got /whatever'
      expect(did_run) == [:app_1, :app_2]
    end
  end

  class NamespaceTest < Test
    def setup
      next_app = proc { |env| "Hi from #{env['PATH_INFO']}" }
      @namespace = Pigeon::Routing::Namespace.new('/auth', next_app)
    end

    def test_match
      response = @namespace.call(Request['POST /auth/login'])
      expect(response) == "Hi from /login"
    end

    def test_mismatch
      response = @namespace.call(Request['POST /blog/login'])
      expect(response).nil?
    end
  end

  class DSLTest < Test
    def setup
      resolver = proc do |key|
        proc do |env|
          chain = Array(env['mock_middleware']) + [key]
          chain.map(&:inspect).join(' -> ')
        end
      end

      @routes = Pigeon::Routing::DSL.new(resolver).define do
        middleware MockMiddleware, :mw_outside

        namespace '/auth' do
          get  '/sign_in' => :sign_in_form
          post '/sign_in' => :sign_in
          post '/sign_out' => :sign_out
          mount :auth_not_found
        end

        group do
          middleware MockMiddleware, :mw_inside
          get  '/' => :home
        end

        mount :not_found
      end
    end

    def test_responses
      {
        'GET  /auth/sign_in'  => ':mw_outside -> :sign_in_form',
        'POST /auth/sign_in'  => ':mw_outside -> :sign_in',
        'GET  /auth/sign_out' => ':mw_outside -> :auth_not_found',
        'GET  /'              => ':mw_outside -> :mw_inside -> :home',
        'GET  /blah'          => ':mw_outside -> :not_found',
      }.each do |request, expected_response|
        response = @routes.call(Request[request])
        expect(response) == expected_response
      end
    end

    def test_default_identity_resolver
      dsl = Pigeon::Routing::DSL.new
      expect(dsl.app_resolver['cat']) == 'cat'
    end

    def test_deep_freezability
      IceNine.deep_freeze(@routes)
      test_responses
    end
  end

  class MockMiddleware
    attr_reader :next_app

    def initialize(next_app, name)
      @next_app = next_app
      @name = name
    end

    def call(env)
      subenv = env.dup
      subenv['mock_middleware'] ||= []
      subenv['mock_middleware'] += [@name]
      @next_app.call(subenv)
    end
  end

  module Request
    def self.[](method_and_path)
      method, _, path = method_and_path.partition(/\s+/)
      {
        'REQUEST_METHOD' => method.strip,
        'PATH_INFO' => path.strip
      }
    end
  end

end
