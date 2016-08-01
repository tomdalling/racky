require 'view'

class Controllers::Home
  include App::Inject[
    works: 'queries.work',
    view: 'templates.home',
  ]

  def call(env)
    #TODO: this needs to be moved into the view layer
    featured = enrich(works.featured)
    latest = enrich(works.latest)

    [200, {}, [
      View.render(view,
        featured_work: featured,
        latest_work: latest,
      )
    ]]
  end

  def enrich(work)
    return unless work

    doc = LIF::JSON::Parser.parse(work.lif_document)
    first_para = doc.scenes.first.paragraphs.first

    blurb_doc = doc.with(scenes: [
      LIF::Scene.with(paragraphs: [first_para]),
    ])

    work.blurb_html = LIF::HTMLConverter.convert(blurb_doc)

    # needs the author to generate the path
    work.path = "/todo/here"

    work
  end
end
