require 'endpoint'
require 'work_decorator'

class Endpoints::ViewWork < Endpoint
  dependencies query: 'queries/work'

  def run
    work = query.call(params.fetch(:user), params.fetch(:work))
    if work
      render(:work, work: WorkDecorator.new(work))
    else
      404
    end
  end
end
