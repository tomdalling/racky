require 'work'

module Queries
  class Work
    include App::Inject['db']

    def featured
      work = db[:works]
          .exclude(featured_at: nil)
          .exclude(published_at: nil)
          .order_by(:featured_at)
          .last
      work ? OpenStruct.new(work) : nil
    end

    def latest
      work = db[:works]
          .order(:published_at)
          .last
      work ? OpenStruct.new(work) : nil
    end

    def find_by_slug(user_name, work_name, viewing_user)
      author_attrs = db[:users].first(machine_name: user_name)
      return nil unless author_attrs

      work_attrs = db[:works].first(user_id: author_attrs.fetch(:id), machine_name: work_name)
      return nil unless work_attrs

      author = OpenStruct.new(author_attrs)
      work = OpenStruct.new(work_attrs.merge(author: author))

      if ::Work.visible_to_user?(work, viewing_user)
        work
      else
        nil
      end
    end
  end
end
