require 'authentication'
require 'endpoint'

class Endpoints::SignIn < Endpoint
  include DefDeps[:page, sign_in: 'commands/sign_in']

  def run
    user = sign_in.call(params.fetch('email'), params.fetch('password'))
    if user
      session.clear
      session[Authentication::SESSION_KEY] = user.id
      redirect('/dashboard')
    else
      page.response(:sign_in,
        error: 'Email or password was incorrect',
        current_user: nil,
      )
    end
  end
end
