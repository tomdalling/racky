require 'models'

class Queries::User
  include DefDeps['db']

  def find(id)
    db[:users]
      .where(id: id)
      .map{ |attrs| User.new(attrs) }
      .first
  end

  def find_by_email(email)
    db[:users]
      .where(email: email)
      .map{ |attrs| User.new(attrs) }
      .first
  end
end
