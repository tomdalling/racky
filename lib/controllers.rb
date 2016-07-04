require 'session'
require 'params'
require 'convenience/controller'

# Temporary in-memory DB.
# TODO: remove this later
USERS = [
  { id: 1, username: 'admin', password: '123' },
]

module Controllers
  class Router
    def initialize(controllers)
      @controllers = controllers
    end

    def call(env)
      route_name = env.fetch('racky.route.name')
      @controllers[route_name].call(env)
    end
  end

  class View
    def initialize(view_name, layout: :layout, status: 200)
      @template = Template.get(view_name)
      @layout = Template.get(layout)
      @status = status
    end

    def call(env, template_args=nil)
      content = @template.render(template_args)
      html = @layout.render(OpenStruct.new(content: content))
      [
        @status,
        { 'Content-Type' => 'text/html' },
        [html],
      ]
    end
  end

  class Redirect
    def initialize(route_name)
      @route_name = route_name
    end

    def call(env, vars={})
      @pattern ||= ::App['routes'].lookup_pattern(@route_name)
      fail "Could not find route named #{@route_name.inspect}" unless @pattern

      [303, { 'Location' => @pattern.construct_path(vars) }, []]
    end
  end

  class SignInForm
    REDIRECT = Redirect.new(:root)
    VIEW = View.new(:sign_in)

    def call(env)
      if env.fetch('racky.authentication.user')
        REDIRECT.call(env)
      else
        VIEW.call(env, error: nil)
      end
    end
  end

  class SignIn < Convenience::Controller
    define_params(
      username: String,
      password: String,
    )

    def call
      user = USERS.find{ |u| u[:username] == params[:username] }

      if user && user[:password] == params[:password]
        session['user_id'] = user[:id]
        redirect(:root)
      else
        view(:sign_in, error: 'Username or password was incorrect')
      end
    end
  end

  class SignOut
    VIEW = View.new(:signed_out)

    def call(env)
      Session.clear(env)
      VIEW.call(env, user: env.fetch('racky.authentication.user'))
    end
  end
end
