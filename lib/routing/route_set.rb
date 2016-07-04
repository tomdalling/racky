class Routing::RouteSet
  attr_reader :subroutes

  def initialize(subroutes)
    @subroutes = subroutes
  end

  def lookup(env)
    @subroutes.each do |sr|
      match = sr.lookup(env)
      return match unless match.nil?
    end

    nil
  end

  def lookup_pattern(name)
    @subroutes
      .lazy
      .map { |sr| sr.lookup_pattern(name) }
      .find { |pattern| pattern != nil }
  end
end
