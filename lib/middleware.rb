module Middleware
  class RouteLookup
    def initialize(next_app, route_set:)
      @next_app = next_app
      @route_set = route_set
    end

    def call(env)
      captures, endpoint = @route_set.lookup(env)
      @next_app.call(env.merge(
        'racky.route.name' => endpoint.fetch(:name),
        'racky.route.captures' => captures,
      ))
    end
  end

  class Authentication
    def initialize(success_app, failure_app:, bypass_routes: [])
      @success_app = success_app
      @failure_app = failure_app
      @bypass_routes = bypass_routes
    end

    def call(env)
      uid = Session.get(env, 'user_id')
      current_user = uid && USERS.find{ |u| u[:id] == uid }

      route_name = env.fetch('racky.route.name')

      success = (current_user || @bypass_routes.include?(route_name))
      next_app = (success ? @success_app : @failure_app)
      next_app.call(env.merge(
        'racky.authentication.user' => current_user
      ))
    end
  end
end
