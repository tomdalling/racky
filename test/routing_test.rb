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
    put  '/foo', :update_foo
    dele '/foo', :delete_foo
    opts '/foo', :foo_options
    ptch '/foo', :update_foo2

    get %r{/foo/\d+}, :foo_regex

    mount MOUNTED_ROUTER
  end

  def test_successful_lookups
    {
      %w(GET /) => :root,
      %w(HEAD /) => :root_head,
      %w(POST /api/sign_in) => :sign_in,
      %w(POST /foo) => :create_foo,
      %w(PUT /foo) => :update_foo,
      %w(DELETE /foo) => :delete_foo,
      %w(OPTIONS /foo) => :foo_options,
      %w(PATCH /foo) => :update_foo2,
      %w(GET /foo/1) => :foo_regex,
      %w(GET /foo/2) => :foo_regex,
      %w(GET /foo/3) => :foo_regex,
      %w(GET /mounted) => :mounted,
    }.each do |req_args, expected_result|
      env = req(*req_args)
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
      env = req(*req_args)
      expect(ROUTER.lookup(env)).is_nil
    end
  end

  def req(method, path)
    {
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path
    }
  end
end
