require 'routing'

class RouterTest < Test
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
    }.each do |req_args, expected_result|
      env = req(*req_args)
      expect ROUTER.lookup(env), :==, expected_result
    end
  end

  def test_failed_lookups
    [
      %w(DELETE /),
      %w(GET /api),
      %w(POST /api),
      %w(GET /api/sign_in),
    ].each do |req_args|
      env = req(*req_args)
      expect ROUTER.lookup(env), :is_nil
    end
  end

  def req(method, path)
    {
      'REQUEST_METHOD' => method,
      'PATH_INFO' => path
    }
  end
end
