class Queries::User
  include App::Inject['db']

  def find(id)
    user = db[:users].find(id).first
    user ? OpenStruct.new(user) : nil
  end

  def find_by_email(email)
    user = db[:users].where(email: email).first
    user ? OpenStruct.new(user) : nil
  end
end
