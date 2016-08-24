require 'endpoint'
require 'work_etag'
require 'view_models/homepage'

class Endpoints::Home < Endpoint
  dependencies query: 'queries/homepage'

  def run
    home = query.call
    etag = WorkETag.generate(home.featured, home.latest)
    anon_cache(etag: etag, max_age: 60) do
      render(:home, home.to_h, ViewModels::Homepage)
    end
  end
end
