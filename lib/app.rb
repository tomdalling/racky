require 'template'
require 'controllers'
require 'middleware'
require 'dry/component/container'
require 'pigeon/routing'

class App < Dry::Component::Container
  namespace 'controllers' do
    register 'sign_in_form', Controllers::SignInForm.new
    register 'sign_in', Controllers::SignIn
    register 'sign_out', Controllers::SignOut.new
    register 'home', Controllers::View.new(:home)
    register 'not_found', Controllers::View.new(:'404', status: 404)
  end

  register 'routing_dsl' do
    resolver = ->(controller_key){ resolve("controllers.#{controller_key}") }
    Pigeon::Routing::DSL.new(resolver)
  end

  register 'routes' do
    resolve('routing_dsl').define do
      namespace '/auth' do
        get  '/sign_in' => :sign_in_form
        post '/sign_in' => :sign_in
        post '/sign_out' => :sign_out
      end

      group do
        middleware Middleware::EnforceAuthenticated,
          failure_app: Controllers::Redirect.new('/auth/sign_in')

        get  '/' => :home
      end

      always :not_found
    end
  end

  register 'root_app' do
    routes = resolve('routes')
    resolve('routing_dsl').define do
      middleware Rack::Session::Cookie,
        key: Session::COOKIE_NAME,
        secret: '#TODO: change_me',
        coder: Rack::Session::Cookie::Base64::ZipJSON.new

      middleware Middleware::Authentication

      mount routes
    end
  end

  finalize!
end
