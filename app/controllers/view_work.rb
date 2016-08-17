require 'lif'
require 'work_decorator'

class Controllers::ViewWork
  include DefDeps[
    :page,
    query: 'queries/work',
  ]

  def call(env)
    params = Params.get(env)
    work = query.call(params.fetch(:user), params.fetch(:work))
    if work
      [200, {}, [page.render(:work,
        work: WorkDecorator.new(work),
      )]]
    else
      [404, {}, ['Not found']]
    end
  end
end
