class Queries::Dashboard
  include App::Inject['db']

  def call(user)
    OpenStruct.new(
      user: user,
      works: db[:works].where(user_id: user.id).map{ |w| OpenStruct.new(w) },
    )
  end
end
