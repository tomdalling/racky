require 'template'
require 'routing'

class App
  ROUTER = Routing.define do
    get  '/', to: :root
    get  '/home', to: :home
    namespace '/auth' do
      get  '/sign_in', to: :sign_in_form
      post '/sign_in', to: :sign_in
      post '/sign_out', to: :sign_out
    end
    always to: :not_found
  end

  def call(env)
    route = ROUTER.lookup(env)
    send(route.fetch(:to), env)
  end

  def not_found(env)
    view '404', {}, 404
  end

  def root(env)
    redirect '/auth/sign_in'
  end

  def home(env)
    view :home
  end

  def sign_in_form(env)
    view :sign_in
  end

  def sign_in(env)
    redirect '/home'
  end

  def sign_out(env)
  end

  def redirect(location)
    [303, { 'Location' => location }, []]
  end

  def view(template_name, context={}, status=200)
    ctx = context.is_a?(Hash) ? OpenStruct.new(context) : context
    content = Template.render(template_name, ctx)
    html = Template.render(:layout, OpenStruct.new(content: content))
    [
      status,
      { 'Content-Type' => 'text/html' },
      [html],
    ]
  end

  def params(env)
    case
    when env['QUERY_STRING'].length > 0
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    when env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
      body = env['rack.input']
      body.rewind
      Rack::Utils.parse_nested_query(body.read)
    else
      {}
    end
  end
end
