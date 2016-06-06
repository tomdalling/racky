class Routing::Namespace
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
