require 'authentication'

class EnforceAuthenticated
  def initialize(next_app)
    @next_app = next_app
  end

  def call(env)
    if Authentication.authenticated?(env)
      @next_app.call(env)
    else
      return_url = URI.escape(env['PATH_INFO'])
      [303, { 'Location' => "/auth/sign_in?return_url=#{return_url}" }, []]
    end
  end
end
