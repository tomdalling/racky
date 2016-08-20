require 'unit_test'
require 'endpoint'

class EndpointTest < UnitTest
  class Dog < Endpoint
    dependencies :woof
    params {{
      return_ivar: boolean,
      render_page: maybe(Symbol),
      response_body: any,
    }}

    def initialize(ivar = nil, dependencies={})
      @ivar = ivar
      super(dependencies)
    end

    def run
      if params[:return_ivar]
        @ivar
      elsif params[:render_page]
        render(*params[:render_page])
      else
        params[:response_body]
      end
    end
  end

  def env(response_body: 'body', return_ivar: false, render_page: nil)
    {
      Pigeon::Routing::CAPTURES_ENV_KEY => {
        response_body: response_body,
        return_ivar: return_ivar,
        render_page: render_page,
      },
    }
  end

  def setup
    @dog = Dog.new('hello', woof: true, page: true)
  end

  def test_cloning
    response = @dog.call(env(return_ivar: true))
    expect(response) == [200, {}, ['hello']]
  end

  def test_response__string
    response = @dog.call(env(response_body: 'woof'))
    expect(response) == [200, {}, ['woof']]
  end

  def test_response__status
    response = @dog.call(env(response_body: 404))
    expect(response) == [404, {}, []]
  end

  def test_response__status_plus_headers
    response = @dog.call(env(response_body: [500, { 'ETag' => 'abc' }]))
    expect(response) == [500, { 'ETag' => 'abc' }, []]
  end

  def test_response__headers_plus_body
    response = @dog.call(env(response_body: [{ 'ETag' => 'abc' }, 'body']))
    expect(response) == [200, { 'ETag' => 'abc' }, ['body']]
  end

  def test_response__status_plus_body
    response = @dog.call(env(response_body: [401, 'body']))
    expect(response) == [401, {}, ['body']]
  end

  def test_response__status_plus_headers_plus_body
    response = @dog.call(env(response_body: [401, {'Etag'=>'abc'}, 'body']))
    expect(response) == [401, {'Etag'=>'abc'}, ['body']]
  end

  def test_response__with_full_rack_response
    response = @dog.call(env(response_body: [401, {'Etag'=>'abc'}, ['body']]))
    expect(response) == [401, {'Etag'=>'abc'}, ['body']]
  end

  def test_redirect
    response = @dog.send(:redirect, '/blah')
    expect(response) == [303, {'Location' => '/blah'}, []]
  end

  def test_frozen
    expect(@dog.frozen?) == true
  end

  def test_def_deps
    expect(@dog.respond_to?(:woof)) == true
  end

  def test_render
    page = Minitest::Mock.new
    dog = Dog.new('woof', woof: true, page: page)

    page.expect(:render, 'poodle', [:bark, { current_user: nil }])
    response = dog.call(env(render_page: :bark))

    expect(response) == [200, {}, ['poodle']]
    page.verify
  end
end
