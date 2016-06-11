require 'rack'

module Session
  COOKIE_NAME = 'racky.session'

  def self.get(env)
    env.fetch('rack.session')
  end
end

module CurrentUser
  extend self

  SESSION_KEY = 'user_id'

  def set(env, user_id)
    Session.get(env)[SESSION_KEY] = user_id
  end

  def get(env)
    Session.get(env)[SESSION_KEY]
  end
end
