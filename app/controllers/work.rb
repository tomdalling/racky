require 'lif'

class Controllers::Work
  include App::Inject[
    works: 'queries.work',
    view: 'templates.work',
  ]

  def call(env)
    params = Params.get(env)
    work = works.find_by_slug(params.fetch(:user), params.fetch(:work))
    if work
      [200, {}, [View.render(view,
        work: work,
        work_body_html: work_body_html(work),
      )]]
    else
      [404, {}, ['Not found']]
    end
  end

  def work_body_html(work)
    doc = LIF::JSON::Parser.parse(work.lif_document)
    LIF::HTMLConverter.convert(doc)
  end
end
