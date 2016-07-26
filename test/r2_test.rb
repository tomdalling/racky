require 'test_helper'
require 'r2'

#TODO: this probably shouldn't be global
module Req
  def self.[](method_and_path)
    method, _, path = method_and_path.partition(/\s+/)
    {
      'REQUEST_METHOD' => method.strip,
      'PATH_INFO' => path.strip
    }
  end
end

class R2PatternTest < Test
  def test_split
    {
      ':foo:bar' => [:foo, :bar],
      '/foo/:id.:format' => ['/foo/', :id, '.', :format],
    }.each do |input, output|
      expect(R2::Pattern.split(input)) == output
    end
  end

  def test_regex
    {
      [:foo, :bar] => %r{\A(?<foo>[^/]+)(?<bar>[^/]+)\z},
      ['/foo/', :id, '.', :format] => %r{\A/foo/(?<id>[^/]+)\.(?<format>[^/]+)\z},
    }.each do |input, output|
      expect(R2::Pattern.regex(input)) == output
    end
  end

  def test_construct_path
    parts = ['/foo/', :id, '.', :format]
    vars = { id: 4, format: 'html' }
    expect(R2::Pattern.construct_path(parts, vars)) == '/foo/4.html'
  end

  def test_object
    p = R2::Pattern.from_string('/foo/:id.:format')
    expect(p.match('/hello')) == nil
    expect(p.match('/foo/3.json')) == { id: '3', format: 'json' }
    expect(p.construct_path(id: 123, format: 'png')) == '/foo/123.png'
  end
end

class R2EndpointTest < Test
  def setup
    pattern = R2::Pattern.from_string('/foo/:id.:format')
    next_app = proc do |env|
      @received_env = env
      [200, {'Header' => 'blah'}, ['Okie Dokie']]
    end
    @endpoint = R2::Endpoint.new('GET', pattern, next_app)
  end

  def teardown
    @endpoint = nil
    @received_env = nil
  end

  def test_match
    response = @endpoint.call(Req['GET /foo/3.json'])
    expect(response) == [200, {'Header' => 'blah'}, ['Okie Dokie']]
    expect(@received_env) == {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/foo/3.json',
      R2::ROUTING_CAPTURES_ENV_KEY => {
        id: '3',
        format: 'json',
      }
    }
  end

  def test_mismatched_http_method
    response = @endpoint.call(Req['POST /foo/3.json'])
    expect(response).nil?
    expect(@received_env).nil?
  end

  def test_mismatched_path
    response = @endpoint.call(Req['GET /foo/wrong/3.json'])
    expect(response).nil?
    expect(@received_env).nil?
  end
end

class R2RouterTest < Test
  def test_routing
    did_run = []
    app_1 = proc { |env| did_run << :app_1; nil }
    app_2 = proc { |env| did_run << :app_2; "Got #{env['PATH_INFO']}" }
    app_3 = proc { |env| did_run << :app_3; nil }
    router = R2::Router.new([app_1, app_2, app_3])

    response = router.call(Req['GET /whatever'])
    expect(response) == 'Got /whatever'
    expect(did_run) == [:app_1, :app_2]
  end
end

class R2NamespaceTest < Test
  def setup
    next_app = proc { |env| "Hi from #{env['PATH_INFO']}" }
    @namespace = R2::Namespace.new('/auth', next_app)
  end

  def test_match
    response = @namespace.call(Req['POST /auth/login'])
    expect(response) == "Hi from /login"
  end

  def test_mismatch
    response = @namespace.call(Req['POST /blog/login'])
    expect(response).nil?
  end
end

class R2DSLTest < Test
  def setup
    resolver = proc do |key|
      proc do |env|
        chain = Array(env['mock_middleware']) + [key]
        chain.map(&:inspect).join(' -> ')
      end
    end

    @dsl = R2::DSL.new(resolver)
  end

  def test_it
    routes = @dsl.define do
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

    {
      'GET  /auth/sign_in'  => ':mw_outside -> :sign_in_form',
      'POST /auth/sign_in'  => ':mw_outside -> :sign_in',
      'GET  /auth/sign_out' => ':mw_outside -> :auth_not_found',
      'GET  /'              => ':mw_outside -> :mw_inside -> :home',
      'GET  /blah'          => ':mw_outside -> :not_found',
    }.each do |request, expected_response|
      response = routes.call(Req[request])
      expect(response) == expected_response
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
end
