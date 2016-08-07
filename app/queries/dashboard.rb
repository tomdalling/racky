class Queries::Dashboard
  include App::Inject['db']

  def call(author)
    OpenStruct.new(
      works: db[:works]
        .where(user_id: author.id)
        .map{ |w| OpenStruct.new(w.merge(author: author)) }
    )
  end
end
