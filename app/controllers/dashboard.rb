require 'authentication'
require 'view'

class Controllers::Dashboard
  include App::Inject[view: 'templates.dashboard']

  def call(env)
    current_user = Authentication.get(env)
    body = View.render(view, { current_user: current_user })
    [200, {}, [body]]
  end
end
