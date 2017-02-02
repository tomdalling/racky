require 'session'

class Authentication
  ENV_KEY = 'litmal.current_user'
  SESSION_KEY = 'litmal.user_id'

  def initialize(next_app, users=nil)
    @next_app = next_app
    @users = users
  end

  def call(env)
    uid = Session.get(env)[SESSION_KEY]
    user = uid && @users.find(uid)
    @next_app.call(env.merge(ENV_KEY => user))
  end

  def self.authenticated?(env)
    get(env) != nil
  end

  def self.get(env)
    env.fetch(ENV_KEY, nil)
  end

  def self.store(session, user_id)
    clear(session)
    session[SESSION_KEY] = user_id
  end

  def self.clear(session)
    session.clear
  end
end
