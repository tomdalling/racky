require 'unit_test'
require 'endpoint'

class EndpointTest < UnitTest
  class Dog < Endpoint
    def initialize(ivar = nil)
      @ivar = ivar
    end

    def run
      if params[:return_ivar]
        @ivar
      else
        params[:response_body]
      end
    end
  end

  def env(response_body, return_ivar: false)
    {
      Pigeon::Routing::CAPTURES_ENV_KEY => {
        response_body: response_body,
        return_ivar: return_ivar,
      },
    }
  end

  def setup
    @dog = Dog.new('hello')
  end

  def test_cloning
    response = @dog.call(env(nil, return_ivar: true))
    expect(response) == [200, {}, ['hello']]
  end

  def test_response__string
    response = @dog.call(env('woof'))
    expect(response) == [200, {}, ['woof']]
  end

  def test_response__status
    response = @dog.call(env(404))
    expect(response) == [404, {}, []]
  end

  def test_response__status_plus_headers
    response = @dog.call(env([500, { 'ETag' => 'abc' }]))
    expect(response) == [500, { 'ETag' => 'abc' }, []]
  end

  def test_response__headers_plus_body
    response = @dog.call(env([{ 'ETag' => 'abc' }, 'body']))
    expect(response) == [200, { 'ETag' => 'abc' }, ['body']]
  end

  def test_response__status_plus_body
    response = @dog.call(env([401, 'body']))
    expect(response) == [401, {}, ['body']]
  end

  def test_response__status_plus_headers_plus_body
    response = @dog.call(env([401, {'Etag'=>'abc'}, 'body']))
    expect(response) == [401, {'Etag'=>'abc'}, ['body']]
  end

  def test_response__with_full_rack_response
    response = @dog.call(env([401, {'Etag'=>'abc'}, ['body']]))
    expect(response) == [401, {'Etag'=>'abc'}, ['body']]
  end

  def test_redirect
    response = @dog.send(:redirect, '/blah')
    expect(response) == [303, {'Location' => '/blah'}, []]
  end

  def test_frozen
    expect(Dog.new.frozen?) == true
  end

  def test_def_deps
    expect(@dog.respond_to?(:woof)) == false
    Dog.dependencies(:woof)
    expect(@dog.respond_to?(:woof)) == true
  end
end
