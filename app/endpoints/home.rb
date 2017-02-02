require 'work_etag'
require 'view_models/homepage'

class Endpoints::Home < RequestHandler
  dependencies query: 'queries/homepage'

  def run
    home = query.call
    etag = WorkETag.generate(home.featured, home.latest)
    anon_cache(etag: etag, max_age: 60) do
      render(:home, home)
    end
  end
end
