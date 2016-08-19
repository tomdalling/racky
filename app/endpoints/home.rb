require 'endpoint'
require 'work_etag'
require 'work_decorator'
require 'http_cache'

class Endpoints::Home < Endpoint
  dependencies query: 'queries/homepage'

  def run
    home = query.call
    etag = WorkETag.generate(home.featured, home.latest)
    cache(etag: etag, max_age: 60) do
      render(:home,
        featured_work: home.featured && WorkDecorator.new(home.featured),
        latest_work: home.latest && WorkDecorator.new(home.latest),
      )
    end
  end
end
