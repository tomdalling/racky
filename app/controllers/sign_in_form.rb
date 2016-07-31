require 'params'

class Controllers::SignInForm
  include App::Inject[view: 'templates.sign_in']

  def call(env)
    current_user = env.fetch(Authentication::ENV_KEY)
    if current_user
      [303, { 'Location' => '/dashboard' }, []]
    else
      params = Params.get(env)
      error = params['return_url'] ? 'You must be signed in to view that page' : nil
      body = View.render(view, error: error, current_user: nil)
      [200, {}, [body]]
    end
  end
end
