require 'work_etag'

class Endpoints::ViewWork < RequestHandler
  dependencies fetch_work: 'queries/work'

  params {{
    user: _String,
    work: _String,
  }}

  def run
    work = fetch_work.(params[:user], params[:work])
    return 404 unless work

    anon_cache(max_age: 60, etag: WorkETag.generate(work)) do
      render(:work, work)
    end
  end
end
