require 'session'
require 'params'
require 'convenience/controller'

# Temporary in-memory DB.
# TODO: remove this later
USERS = [
  { id: 1, username: 'admin', password: '123' },
]

module Controllers
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
    def initialize(location)
      @location = location
    end

    def call(env)
      [303, { 'Location' => @location }, []]
    end
  end

  class SignInForm
    REDIRECT = Redirect.new('/')
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
        redirect('/')
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
