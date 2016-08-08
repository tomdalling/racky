require 'view'
require 'work_decorator'
require 'http_cache'

class Controllers::Home
  include App::Inject[
    query: 'queries.homepage',
    view: 'templates.home',
  ]

  def call(env)
    home = query.call
    HTTPCache.if_none_match(etag(home), env) do
      [
        View.render(view,
          featured_work: WorkDecorator.new(home.featured),
          latest_work: WorkDecorator.new(home.latest),
        )
      ]
    end
  end

  # TODO: this is too manual. needs some sort of etag generator
  #       that is easier to use
  def etag(home)
    # TODO: don't use published_at. Use updated_at or something.
    parts = "controllers.home-"
    parts << home.featured.id
    parts << home.featured.published_at.iso8601
    parts << home.latest.id
    parts << home.latest.published_at.iso8601
    Digest::MD5.hexdigest(parts)
  end
end
