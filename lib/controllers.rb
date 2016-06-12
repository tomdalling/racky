require 'current_user'
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
      if CurrentUser.get(env)
        REDIRECT.call(env)
      else
        VIEW.call(env, error: nil)
      end
    end
  end

  class SignIn
    REDIRECT = Redirect.new('/')

    def call(env)
      params = Params.require!(env, {
        username: String,
        password: String,
      })
      user = USERS.find{ |u| u[:username] == params[:username] }

      if user && user[:password] == params[:password]
        CurrentUser.set(env, user[:id])
        REDIRECT.call(env)
      else
        SignInForm::VIEW.call(env, error: 'Username or password was incorrect')
      end
    end
  end

  class SignOut
    VIEW = View.new(:signed_out)

    def call(env)
      CurrentUser.set(env, nil)
      VIEW.call(env)
    end
  end
end
