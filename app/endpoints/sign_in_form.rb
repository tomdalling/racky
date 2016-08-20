require 'endpoint'

class Endpoints::SignInForm < Endpoint
  params {{
    _?('return_url') => String
  }}

  def run
    if current_user
       redirect('/dashboard')
    else
      error = params['return_url'] ? 'You must be signed in to view that page' : nil
      render(:sign_in, error: error)
    end
  end
end
