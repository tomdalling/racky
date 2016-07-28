module Repos
  class Work
    def create(attrs)
      @@db ||= []
      @@db.concat(Array(attrs))
    end
  end
end
