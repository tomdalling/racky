require 'endpoint'
require 'work_decorator'
require 'work_etag'

class Endpoints::ViewWork < Endpoint
  dependencies query: 'queries/work'
  params {{
    user: String,
    work: String,
  }}

  def run
    work = query.call(params.fetch(:user), params.fetch(:work))
    if work
      anon_cache(max_age: 60, etag: WorkETag.generate(work)) do
        render(:work, work: WorkDecorator.new(work))
      end
    else
      404
    end
  end
end
