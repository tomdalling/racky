require 'endpoint'
require 'work_etag'
require 'view_models/view_work'

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
        render(:work, work)
      end
    else
      404
    end
  end
end
