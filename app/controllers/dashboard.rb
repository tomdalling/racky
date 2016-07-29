require 'authentication'

class Controllers::Dashboard
  include App::Inject[view: 'views.dashboard']

  def call(env)
    current_user = env.fetch(Authentication::ENV_KEY)
    body = view.render(current_user)
    [200, {}, [body]]
  end
end
