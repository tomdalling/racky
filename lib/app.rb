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
    authentication_failed: Redirect.new('/auth/sign_in'),
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

  def params(env)
    case
    when env['QUERY_STRING'].length > 0
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    when env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
      body = env['rack.input']
      body.rewind
      Rack::Utils.parse_nested_query(body.read)
    else
      {}
    end
  end
end
