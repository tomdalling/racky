require 'params'
require 'session'
require 'authentication'
require 'password'

class Controllers::SignIn
  include DefDeps[
    :page,
    users: 'queries/user',
  ]

  def call(env)
    params = Params.get(env)
    user = users.find_by_email(params.fetch('email'))
    if user && Password.compare(params.fetch('password'), user.password_hash)
      Session.clear(env)
      session = Session.get(env)
      session[Authentication::SESSION_KEY] = user.id
      [303, { 'Location' => '/dashboard' }, []]
    else
      body = page.render(:sign_in, error: 'Email or password was incorrect', current_user: nil)
      [200, {}, [body]]
    end
  end
end
