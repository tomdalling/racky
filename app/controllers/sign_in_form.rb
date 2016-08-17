require 'params'

class Controllers::SignInForm
  include DefDeps[:page]

  def call(env)
    current_user = Authentication.get(env)
    if current_user
      [303, { 'Location' => '/dashboard' }, []]
    else
      params = Params.get(env)
      error = params['return_url'] ? 'You must be signed in to view that page' : nil
      body = page.render(:sign_in, error: error, current_user: nil)
      [200, {}, [body]]
    end
  end
end
