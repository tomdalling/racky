class Routing::Always
  def initialize(options)
    @options = options
  end

  def lookup(env)
    [{}, @options]
  end

  def lookup_pattern(name)
    nil
  end
end
