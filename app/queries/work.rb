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

    def find_by_slug(user_name, work_name)
      user = db[:users].first(machine_name: user_name)
      return nil unless user

      work = db[:works].first(user_id: user.fetch(:id), machine_name: work_name)
      return nil unless work

      OpenStruct.new(work)
    end
  end
end
