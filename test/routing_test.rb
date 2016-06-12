require 'test_helper'
require 'routing'

class RouterTest < Test
  MOUNTED_ROUTER = Routing::Endpoint.new('GET', '/mounted', :mounted)
  ROUTER = Routing.define do
    get  '/', :root
    head '/', :root_head

    namespace '/api' do
      post '/sign_in', :sign_in
    end

    post '/foo', :create_foo
    opts '/foo', :foo_options
    get  '/foo/:id.:format', :show_foo
    put  '/foo/:id', :update_foo
    dele '/foo/:id', :delete_foo
    ptch '/foo/:id', :update_foo2

    mount MOUNTED_ROUTER
  end

  def request(method, path)
    {
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path
    }
  end

  def test_successful_lookups
    {
      %w(GET /) => [{}, :root],
      %w(HEAD /) => [{}, :root_head],
      %w(POST /api/sign_in) => [{}, :sign_in],
      %w(POST /foo) => [{}, :create_foo],
      %w(OPTIONS /foo) => [{}, :foo_options],
      %w(GET /foo/6.json) => [{id: '6', format: 'json'}, :show_foo],
      %w(PUT /foo/5) => [{id: '5'}, :update_foo],
      %w(DELETE /foo/4) => [{id: '4'}, :delete_foo],
      %w(PATCH /foo/3) => [{id: '3'}, :update_foo2],
      %w(GET /mounted) => [{}, :mounted],
    }.each do |req_args, expected_result|
      env = request(*req_args)
      expect(ROUTER.lookup(env)) == expected_result
    end
  end

  def test_failed_lookups
    [
      %w(DELETE /),
      %w(GET /api),
      %w(POST /api),
      %w(GET /api/sign_in),
      %w(GET /foo/abc),
      %w(GET /foo/),
    ].each do |req_args|
      env = request(*req_args)
      expect(ROUTER.lookup(env)).is_nil
    end
  end

  def test_pattern_split
    {
      ':foo:bar' => [:foo, :bar],
      '/foo/:id.:format' => ['/foo/', :id, '.', :format],
    }.each do |input, output|
      expect(Routing::Pattern.split(input)) == output
    end
  end

  def test_pattern_regex
    {
      [:foo, :bar] => %r{\A(?<foo>[^/]+)(?<bar>[^/]+)\z},
      ['/foo/', :id, '.', :format] => %r{\A/foo/(?<id>[^/]+)\.(?<format>[^/]+)\z},
    }.each do |input, output|
      expect(Routing::Pattern.regex(input)) == output
    end
  end

  def test_pattern
    p = Routing::Pattern.new('/foo/:id.:format')
    expect(p.match('/foo/3.json')) == { id: '3', format: 'json' }
    expect(p.construct_path(id: 123, format: 'png')) == '/foo/123.png'
  end
end
