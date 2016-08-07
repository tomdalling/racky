class Queries::Homepage
  include App::Inject['db']

  def call
    featured = featured_work
    latest = latest_work
    preload_author!([featured, latest])

    OpenStruct.new(
      featured: featured,
      latest: latest,
    )
  end

  def latest_work
    work = db[:works]
        .order(:published_at)
        .last
    work ? OpenStruct.new(work) : nil
  end

  def featured_work
    work = db[:works]
        .exclude(featured_at: nil)
        .exclude(published_at: nil)
        .order_by(:featured_at)
        .last
    work ? OpenStruct.new(work) : nil
  end

  def preload_author!(works)
    uids = works.map{ |w| w.user_id }
    authors = db[:users].where(id: uids).to_hash(:id)

    works.each do |w|
      w.author = OpenStruct.new(authors.fetch(w.user_id))
    end
  end
end
