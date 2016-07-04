require 'template'
require 'routing'
require 'controllers'
require 'middleware'
require 'dry/component/container'

class App < Dry::Component::Container
  configure do |config|
    config.root = Pathname.new(File.expand_path('../..', __FILE__))
    config.auto_register = 'lib'
  end

  register('routes', Routing.define do
    get  '/', name: :root
    namespace '/auth' do
      get  '/sign_in', name: :sign_in_form
      post '/sign_in', name: :sign_in
      post '/sign_out', name: :sign_out
    end
    always name: :not_found
  end)

  register 'controllers', {
    # authentication not required
    not_found: Controllers::View.new(:'404', status: 404),
    sign_in_form: Controllers::SignInForm.new,
    sign_in: Controllers::SignIn,

    # authentication required
    root: Controllers::View.new(:home),
    sign_out: Controllers::SignOut.new,
  }

  register 'root_app' do
    Rack::Builder.new do
      use Rack::Session::Cookie,
        key: Session::COOKIE_NAME,
        secret: '#TODO: change_me',
        coder: Rack::Session::Cookie::Base64::ZipJSON.new

      use Middleware::RouteLookup,
        route_set: App['routes']

      use Middleware::Authentication,
        failure_app: Controllers::Redirect.new(:sign_in_form),
        bypass_routes: [:not_found, :sign_in_form, :sign_in]

      run Controllers::Router.new(App['controllers'])
    end
  end

  finalize!
end
