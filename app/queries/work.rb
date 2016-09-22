class Queries::Work
  include DefDeps['db']

  def call(user_machine_name, work_machine_name)
    author_attrs = db[:users].first(machine_name: user_machine_name)
    return nil unless author_attrs
    author = User.new(author_attrs)

    work_attrs = db[:works].first(machine_name: work_machine_name, user_id: author.id)
    return nil unless work_attrs

    Work.new(work_attrs.merge(author: author))
  end
end
