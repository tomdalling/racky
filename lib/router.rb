class Router
  def initialize(subrouters)
    @subrouters = subrouters
  end

  def lookup(env)
    @subrouters.each do |sr|
      match = sr.lookup(env)
      return match unless match.nil?
    end

    nil
  end

  class Endpoint
    def initialize(path, target)
      @path = path
      @target = target
    end

    def lookup(env)
      @path === env['PATH_INFO'] ? @target : nil
    end
  end

  class SubRouter
    def initialize(prefix, subrouter)
      @prefix = prefix
      @subrouter = subrouter
    end

    def lookup(env)
      path = env['PATH_INFO']
      if path.start_with?(@prefix)
        subenv = env.dup
        subenv['PATH_INFO'] = path[@prefix.length..-1]
        @subrouter.lookup(subenv)
      else
        nil
      end
    end
  end
end

