require 'models'

class Queries::Homepage
  include DefDeps['db']

  Result = Pigeon::Struct.define do
    def_attr :featured
    def_attr :latest
  end

  def call
    featured, latest = preload_authors(featured_work, latest_work)

    Result.new(
      featured: featured,
      latest: latest,
    )
  end

  def latest_work
    db[:works]
      .reverse_order(:published_at)
      .limit(1)
      .map { |attrs| Work.new(attrs) }
      .first
  end

  def featured_work
    db[:works]
      .exclude(featured_at: nil)
      .exclude(published_at: nil)
      .reverse_order(:featured_at)
      .map { |attrs| Work.new(attrs) }
      .first
  end

  def preload_authors(*works)
    uids = works.compact.map{ |w| w.user_id }
    authors = db[:users].where(id: uids).to_hash(:id)

    works.map do |w|
      w ? w.with(author: User.new(authors.fetch(w.user_id))) : nil
    end
  end
end
