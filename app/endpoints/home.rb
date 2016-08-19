require 'work_decorator'
require 'http_cache'
require 'endpoint'

class Endpoints::Home < Endpoint
  dependencies query: 'queries/homepage'

  def run
    home = query.call
    cache(etag: etag(home)) do
      render(:home,
        featured_work: home.featured && WorkDecorator.new(home.featured),
        latest_work: home.latest && WorkDecorator.new(home.latest),
      )
    end
  end

  # TODO: this is too manual. needs some sort of etag generator
  #       that is easier to use
  def etag(home)
    # TODO: don't use published_at. Use updated_at or something.
    parts = "controllers.home-"
    parts << home.featured.id if home.featured
    parts << home.featured.published_at.iso8601 if home.featured
    parts << home.latest.id if home.latest
    parts << home.latest.published_at.iso8601 if home.latest
    Digest::MD5.hexdigest(parts)
  end
end
