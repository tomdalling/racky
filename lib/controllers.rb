require 'session'
require 'params'

# Temporary in-memory DB.
# TODO: remove this later
USERS = [
  { id: 1, username: 'admin', password: '123' },
]

module Controllers
  class View
    def initialize(view_name, options={})
      @template = Template.get(view_name)
      @layout = Template.get(options.fetch(:layout, :layout))
      @status = options.fetch(:status, 200)
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
      @pattern ||= ::App::ROUTER.lookup_pattern(@route_name)
      fail "Could not find route named #{@route_name.inspect}" unless @pattern

      [303, { 'Location' => @pattern.construct_path(vars) }, []]
    end
  end

  class Authenticator
    FAILURE = Redirect.new(:sign_in)

    def initialize(controller)
      @controller = controller
    end

    def call(env)
      uid = Session.get(env, 'user_id')
      user = uid && USERS.find{ |u| u[:id] == uid }
      if user
        @controller.call(env.merge(racky_current_user: user))
      else
        FAILURE.call(env)
      end
    end
  end

  class SignInForm
    REDIRECT = Redirect.new(:root)
    VIEW = View.new(:sign_in)

    def call(env)
      if env[:racky_current_user]
        REDIRECT.call(env)
      else
        VIEW.call(env, error: nil)
      end
    end
  end

  class SignIn
    SUCCESS_REDIRECT = Redirect.new(:root)
    PARAMS = Params.define(
      username: String,
      password: String,
    )

    def call(env)
      params = PARAMS.get!(env)
      user = USERS.find{ |u| u[:username] == params[:username] }

      if user && user[:password] == params[:password]
        Session.set(env, 'user_id' => user[:id])
        SUCCESS_REDIRECT.call(env)
      else
        SignInForm::VIEW.call(env, error: 'Username or password was incorrect')
      end
    end
  end

  class SignOut
    VIEW = View.new(:signed_out)

    def call(env)
      Session.clear(env)
      VIEW.call(env, user: env[:racky_current_user])
    end
  end
end
