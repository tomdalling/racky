require 'authentication'
require 'view'

class Controllers::Dashboard
  include App::Inject[
    query: 'queries.dashboard',
    view: 'templates.dashboard',
  ]

  def call(env)
    current_user = Authentication.get(env)
    dashboard = query.call(current_user)
    dashboard.works.each do |work|
      work.path = "/@#{current_user.machine_name}/#{work.machine_name}"
    end
    body = View.render(view, current_user: current_user, dashboard: dashboard)
    [200, {}, [body]]
  end
end
