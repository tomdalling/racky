require 'work_decorator'

class Endpoints::Dashboard < Endpoint
  dependencies query: 'queries/dashboard'

  def run
    dashboard = query.call(current_user)
    render(:dashboard,
      works: dashboard.works.map{ |w| WorkDecorator.new(w) },
    )
  end
end
