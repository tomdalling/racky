class Routing::Router
  attr_reader :subrouters

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

  def lookup_pattern(name)
    @subrouters.each do |sr|
      pattern = sr.lookup_pattern(name)
      return pattern if pattern
    end

    nil
  end
end
