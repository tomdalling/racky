module Queries
  class Work
    # TODO: get a real DB in here
    #include App::Inject[]

    def featured
      OpenStruct.new(title: 'Featured Peatured')
    end

    def latest
      OpenStruct.new(title: 'Latest Baitest')
    end
  end
end
