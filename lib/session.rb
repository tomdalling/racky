require 'rack'

module Session
  COOKIE_NAME = 'racky.session'

  def self.get(env, key=nil)
    session = env.fetch('rack.session')
    key ? session[key] : session
  end

  def self.set(env, attrs)
    session = get(env)
    attrs.each do |key, value|
      session[key] = value
    end
  end
end
