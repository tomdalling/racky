module Repos
  class Work
    include App::Inject['db']

    def table
      db[:works]
    end

    def create(attrs)
      Array(attrs).each do |a|
        table.insert(a)
      end
    end
  end
end
