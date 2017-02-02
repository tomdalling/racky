class Commands::UpdateBio
  include DefDeps['db']

  def call(attrs, user)
    db[:users]
      .where(id: user.id)
      .update(attrs)

    nil
  end
end
