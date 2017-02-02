require 'authentication'

class Endpoints::SignIn < RequestHandler
  dependencies sign_in: 'commands/sign_in'
  params {{
    email: _String,
    password: _String,
  }}

  def run
    user = sign_in.call(params[:email], params[:password])
    if user
      session.clear
      session[Authentication::SESSION_KEY] = user.id
      redirect('/dashboard')
    else
      render :sign_in, { error: 'Email or password was incorrect' }
    end
  end
end

