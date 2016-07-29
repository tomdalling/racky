require 'params'

class Controllers::SignInForm
  include App::Inject[view: 'views.sign_in']

  def call(env)
    params = Params.get(env)
    body = view.render(error: params['return_url'] ? 'You must be signed in to view that page' : nil) 
    [200, {}, [body]]
  end
end
