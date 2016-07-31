require 'authentication'

class EnforceAuthenticated
  def initialize(next_app)
    @next_app = next_app
  end

  def call(env)
    if Authentication.get(env)
      @next_app.call(env)
    else
      #TODO: return url
      return_url = URI.escape('whatever')
      [303, { 'Location' => "/auth/sign_in?return_url=#{return_url}" }, []]
    end
  end
end
