class Routing::Always
  def initialize(target)
    @target = target
  end

  def lookup(env)
    @target
  end
end
