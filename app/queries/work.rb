module Queries
  class Work
    include App::Inject['db']

    def featured
      OpenStruct.new(
        db[:works]
          .exclude(featured_at: nil)
          .order_by(:featured_at)
          .last
      )
    end

    def latest
      OpenStruct.new(
        db[:works]
          .order(:published_at)
          .last
      )
    end
  end
end
