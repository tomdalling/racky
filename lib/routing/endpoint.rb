class Routing::Endpoint
  def initialize(method, path, target)
    @method = method.upcase
    @path = path
    @target = target
  end

  def lookup(env)
    matched = (
      @method == env['REQUEST_METHOD'].upcase &&
      @path === env['PATH_INFO']
    )

    matched ? @target : nil
  end
end
