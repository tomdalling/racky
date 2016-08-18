require 'params'
require 'session'
require 'authentication'
require 'password'

class Endpoints::SignIn
  include DefDeps[:page, sign_in: 'commands/sign_in']

  def call(env)
    params = Params.get(env)
    user = sign_in.call(params.fetch('email'), params.fetch('password'))
    if user
      Session.clear(env)
      session = Session.get(env)
      session[Authentication::SESSION_KEY] = user.id
      [303, { 'Location' => '/dashboard' }, []]
    else
      page.response(:sign_in,
        error: 'Email or password was incorrect',
        current_user: nil,
      )
    end
  end
end
