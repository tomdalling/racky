require 'authentication'
require 'view'
require 'work_decorator'

class Controllers::Dashboard
  include App::Inject[
    query: 'queries.dashboard',
    view: 'templates.dashboard',
  ]

  def call(env)
    current_user = Authentication.get(env)
    dashboard = query.call(current_user)
    body = View.render(view,
      current_user: current_user,
      works: dashboard.works.map{ |w| WorkDecorator.new(w) },
    )
    [200, {}, [body]]
  end
end
