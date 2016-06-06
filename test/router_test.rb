require 'router'

class RouterTest < Test
  ROUTER = Router.new([
    Router::Endpoint.new('/', :root),
    Router::SubRouter.new('/api', Router.new([
      Router::Endpoint.new('/sign_in', :sign_in),
    ])),
    Router::Endpoint.new('/foo', :foo),
  ])

  def test_lookup
    expect ROUTER.lookup({ 'PATH_INFO' => '/' }), :==, :root
    expect ROUTER.lookup({ 'PATH_INFO' => '/foo' }), :==, :foo
    expect ROUTER.lookup({ 'PATH_INFO' => '/bar' }), :is_nil
    expect ROUTER.lookup({ 'PATH_INFO' => '/api/sign_in' }), :==, :sign_in
  end
end
