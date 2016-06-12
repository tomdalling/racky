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
      if Session.get(env, 'user_id')
        REDIRECT.call(env)
      else
        VIEW.call(env, error: nil)
      end
    end
  end

  class SignIn
    SUCCESS_REDIRECT = Redirect.new('/')
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
      Session.set(env, 'user_id' => nil)
      VIEW.call(env)
    end
  end
end
