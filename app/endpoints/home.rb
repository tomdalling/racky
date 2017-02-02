require 'work_etag'

module Endpoints
  class Home < RequestHandler
    dependencies fetch_homepage: 'queries/homepage'

    def run
      home = fetch_homepage.()
      etag = WorkETag.generate(home.featured, home.latest)
      anon_cache(etag: etag, max_age: 60) do
        render(:home, home)
      end
    end
  end
end
