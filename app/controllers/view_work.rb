require 'lif'
require 'work_decorator'

class Controllers::ViewWork
  include App::Inject[
    query: 'queries.work',
    view: 'templates.work',
  ]

  def call(env)
    params = Params.get(env)
    work = query.call(params.fetch(:user), params.fetch(:work))
    if work
      [200, {}, [View.render(view,
        work: WorkDecorator.new(work),
      )]]
    else
      [404, {}, ['Not found']]
    end
  end
end
