require 'view'
require 'work_decorator'

class Controllers::Home
  include App::Inject[
    query: 'queries.homepage',
    view: 'templates.home',
  ]

  def call(env)
    home = query.call
    [200, {}, [
      View.render(view,
        featured_work: WorkDecorator.new(home.featured),
        latest_work: WorkDecorator.new(home.latest),
      )
    ]]
  end
end
