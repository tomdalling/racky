require 'authentication'
require 'endpoint'

class Endpoints::SignIn < Endpoint
  dependencies sign_in: 'commands/sign_in'

  def run
    user = sign_in.call(params['email'], params['password'])
    if user
      session.clear
      session[Authentication::SESSION_KEY] = user.id
      redirect('/dashboard')
    else
      render(:sign_in,
        error: 'Email or password was incorrect',
        current_user: nil,
      )
    end
  end
end
