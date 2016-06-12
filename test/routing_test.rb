require 'test_helper'
require 'routing'

class RouterTest < Test
  MOUNTED_ROUTER = Routing::Endpoint.new('GET', '/mounted', name: :mounted)
  ROUTER = Routing.define do
    get  '/', name: :root
    head '/', name: :root_head

    namespace '/api' do
      post '/sign_in', name: :sign_in
      get  '/something/:id', name: :api_something
    end

    post '/foo', name: :create_foo
    opts '/foo', name: :foo_options
    get  '/foo/:id.:format', name: :show_foo
    put  '/foo/:id', name: :update_foo
    dele '/foo/:id', name: :delete_foo
    ptch '/foo/:id', name: :update_foo2

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
      %w(GET /) => [{}, { name: :root }],
      %w(HEAD /) => [{}, { name: :root_head }],
      %w(POST /api/sign_in) => [{}, { name: :sign_in }],
      %w(POST /foo) => [{}, { name: :create_foo }],
      %w(OPTIONS /foo) => [{}, { name: :foo_options }],
      %w(GET /foo/6.json) => [{id: '6', format: 'json'}, { name: :show_foo }],
      %w(PUT /foo/5) => [{id: '5'}, { name: :update_foo }],
      %w(DELETE /foo/4) => [{id: '4'}, { name: :delete_foo }],
      %w(PATCH /foo/3) => [{id: '3'}, { name: :update_foo2 }],
      %w(GET /mounted) => [{}, { name: :mounted }],
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
      %w(GET /foo/.json),
      %w(GET /foo/5),
    ].each do |req_args|
      env = request(*req_args)
      expect(ROUTER.lookup(env)).is_nil
    end
  end

  def test_path_construction
    {
      root: [{}, '/'],
      root_head: [{}, '/'],
      sign_in: [{}, '/api/sign_in'],
      api_something: [{id: 123}, '/api/something/123'],
      show_foo: [{id: 543, format: 'jpg'}, '/foo/543.jpg'],
    }.each do |name, (vars, output)|
      pattern = ROUTER.lookup_pattern(name)
      expect(pattern).is_not_nil
      expect(pattern.construct_path(vars)) == output
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
    p = Routing::Pattern.from_string('/foo/:id.:format')
    expect(p.match('/foo/3.json')) == { id: '3', format: 'json' }
    expect(p.construct_path(id: 123, format: 'png')) == '/foo/123.png'
  end
end
