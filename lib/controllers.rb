require 'current_user'

module Controllers
  class View
    def initialize(view_name, options={})
      @template = Template.get(view_name)
      @layout = Template.get(options.fetch(:layout, :layout))
      @status = options.fetch(:status, 200)
    end

    def call(env)
      content = @template.render
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

  class SignIn
    REDIRECT = Redirect.new('/')

    def call(env)
      CurrentUser.set(env, 123)
      REDIRECT.call(env)
    end
  end

  class SignInForm
    REDIRECT = Redirect.new('/')
    VIEW = View.new(:sign_in)

    def call(env)
      if CurrentUser.get(env)
        REDIRECT.call(env)
      else
        VIEW.call(env)
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
