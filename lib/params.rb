require 'pigeon/routing'

module Params

  def self.get(env)
    from_request(env).merge(from_routing(env))
  end

  def self.from_request(env)
    content_type = env.fetch('CONTENT_TYPE', '')

    case
    when env.fetch('QUERY_STRING', '').length > 0
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    when content_type == 'application/x-www-form-urlencoded'
      body = env['rack.input']
      body.rewind
      Rack::Utils.parse_nested_query(body.read)
    when content_type.start_with?('multipart/form-data')
      Rack::Multipart.parse_multipart(env)
    else
      {}
    end
  end

  def self.from_routing(env)
    env.fetch(Pigeon::Routing::CAPTURES_ENV_KEY, {})
  end

end
