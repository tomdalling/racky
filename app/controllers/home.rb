require 'view'

class Controllers::Home
  include App::Inject[
    query: 'queries.homepage',
    view: 'templates.home',
  ]

  def call(env)
    home = query.call
    [200, {}, [
      View.render(view,
        featured_work: enrich!(home.featured),
        latest_work: enrich!(home.latest),
      )
    ]]
  end

  #TODO: this needs to be moved into the view layer
  def enrich!(work)
    return unless work

    doc = LIF::JSON::Parser.parse(work.lif_document)
    first_para = doc.scenes.first.paragraphs.first

    blurb_doc = doc.with(scenes: [
      LIF::Scene.with(paragraphs: [first_para]),
    ])

    work.blurb_html = LIF::HTMLConverter.convert(blurb_doc)

    # needs the author to generate the path
    work.path = "/@#{work.author.machine_name}/#{work.machine_name}"

    work
  end
end
