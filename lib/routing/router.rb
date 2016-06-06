class Routing::Router
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
end
