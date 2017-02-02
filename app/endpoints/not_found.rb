class Endpoints::NotFound
  def call(env)
    if ENV['RACK_ENV'] == 'test'
      fail "No route for: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
    else
      [404, {}, ['Not Found']]
    end
  end
end
