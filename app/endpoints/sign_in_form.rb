class Endpoints::SignInForm < RequestHandler
  params {{
    optional(:return_url) => _String
  }}

  def run
    if current_user
       redirect(HrefFor.dashboard)
    else
      error = params[:return_url] ? 'You must be signed in to view that page' : nil
      render(:sign_in, error: error, return_url: params[:return_url])
    end
  end
end
