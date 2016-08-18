require 'password'

class Commands::SignIn
  include DefDeps[users: 'queries/user']

  def call(email, password)
    user = users.find_by_email(email)
    if user && Password.compare(password, user.password_hash)
      user
    else
      nil
    end
  end
end
