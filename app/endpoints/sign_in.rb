require 'authentication'

class Endpoints::SignIn < RequestHandler
  dependencies sign_in: 'commands/sign_in'
  params {{
    email: _String,
    password: _String,
    optional(:return_url) => _String,
  }}

  def run
    user = sign_in.(params[:email], params[:password])
    if user
      Authentication.store(session, user.id)
      redirect(params[:return_url] || HrefFor.dashboard)
    else
      render(:sign_in,
        error: 'Email or password was incorrect',
        return_url: params[:return_url],
      )
    end
  end
end
