require 'params'
require 'session'
require 'authentication'

class Controllers::SignIn
  include App::Inject[
    users: 'queries.user',
    view: 'templates.sign_in',
  ]

  def call(env)
    params = Params.get(env)
    user = users.find_by_email(params.fetch('email'))
    if user && user.password == params.fetch('password')
      session = Session.get(env)
      session[Authentication::SESSION_KEY] = user.id
      [303, { 'Location' => '/dashboard' }, []]
    else
      body = View.render(view, error: 'Email or password was incorrect', current_user: nil)
      [200, {}, [body]]
    end
  end
end
