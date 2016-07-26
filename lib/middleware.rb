module Middleware
  class Authentication
    def initialize(next_app)
      @next_app = next_app
    end

    def call(env)
      uid = Session.get(env, 'user_id')
      current_user = uid && USERS.find{ |u| u[:id] == uid }
      @next_app.call(env.merge(
        'racky.authentication.user' => current_user
      ))
    end
  end

  class EnforceAuthenticated
    def initialize(next_app, failure_app:)
      @success_app = next_app
      @failure_app = failure_app
    end

    def call(env)
      current_user = env.fetch('racky.authentication.user')
      next_app = (current_user ? @success_app : @failure_app)
      next_app.call(env)
    end
  end
end
