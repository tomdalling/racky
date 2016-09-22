require 'models'

class Queries::Dashboard
  include DefDeps['db']

  Result = Pigeon::Struct.define do
    def_attr :works
  end

  def call(author)
    Result.new(
      works: db[:works]
        .where(user_id: author.id)
        .map{ |w| Work.new(w.merge(author: author)) }
    )
  end
end
