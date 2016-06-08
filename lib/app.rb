require 'template'
require 'routing'

class App
  ROUTER = Routing.define do
    get  '/', :root
  end

  def call(env)
    method = ROUTER.lookup(env)
    if method
      send(method, env)
    else
      [404, {}, ['404 Not Found']]
    end
  end

  def root(env)
    tpl_args = OpenStruct.new({
      title: 'Root',
      content: env.inspect,
    })

    [
      200,
      { 'Content-Type' => 'text/html' },
      [Template.render(:layout, tpl_args)]
    ]
  end
end
