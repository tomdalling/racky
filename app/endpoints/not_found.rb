class Endpoints::NotFound
  def call(env)
    if ENV['RACK_ENV'] == 'test'
      raise "No route for: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
    end

    [404, {}, ['Not Found']]
  end
end
