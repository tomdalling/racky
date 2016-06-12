require 'template'
require 'routing'
require 'controllers'

class App
  ROUTER = Routing.define do
    get  '/', name: :root
    namespace '/auth' do
      get  '/sign_in', name: :sign_in_form
      post '/sign_in', name: :sign_in
      post '/sign_out', name: :sign_out
    end
    always name: :not_found
  end

  PUBLIC_CONTROLLERS = {
    not_found: Controllers::View.new(:'404', status: 404),
    sign_in_form: Controllers::SignInForm.new,
    sign_in: Controllers::SignIn.new,
  }

  AUTHENTICATED_CONTROLLERS = {
    root: Controllers::View.new(:home),
    sign_out: Controllers::SignOut.new,
  }
    .map { |name, controller| [name, Controllers::Authenticator.new(controller)] }
    .to_h

  CONTROLLERS = PUBLIC_CONTROLLERS.merge(AUTHENTICATED_CONTROLLERS)

  def call(env)
    captures, route = ROUTER.lookup(env)
    name = route.fetch(:name)
    CONTROLLERS.fetch(name).call(env)
  end
end
