require 'authentication'
require 'work_decorator'

class Controllers::Dashboard
  include DefDeps[:page, query: 'queries/dashboard']

  def call(env)
    current_user = Authentication.get(env)
    dashboard = query.call(current_user)
    body = page.render(:dashboard,
      current_user: current_user,
      works: dashboard.works.map{ |w| WorkDecorator.new(w) },
    )
    [200, {}, [body]]
  end
end
