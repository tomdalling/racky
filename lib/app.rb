require 'template'
require 'routing'
require 'controllers'

class App
  ROUTER = Routing.define do
    get  '/', to: :home
    namespace '/auth' do
      get  '/sign_in', to: :sign_in_form, authenticate: false
      post '/sign_in', to: :sign_in, authenticate: false
      post '/sign_out', to: :sign_out
    end
    always to: :not_found, authenticate: false
  end

  CONTROLLERS = {
    home: Controllers::View.new(:home),
    sign_in_form: Controllers::SignInForm.new,
    sign_in: Controllers::SignIn.new,
    sign_out: Controllers::SignOut.new,
    not_found: Controllers::View.new(:'404', status: 404),
    authentication_failed: Controllers::Redirect.new('/auth/sign_in'),
  }

  def call(env)
    route = ROUTER.lookup(env)
    authenticate = route.fetch(:authenticate, true)
    name = if CurrentUser.get(env) || !authenticate
             route.fetch(:to)
           else
             :authentication_failed
           end

    CONTROLLERS.fetch(name).call(env)
  end
end
