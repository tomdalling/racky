class Controllers::Home
  include App::Inject[
    works: 'queries.work',
    template: 'templates.home',
    layout: 'templates.layout',
  ]

  def call(env)
    [200, {}, [
      layout.render(
        title: 'Litmal – Share nice readable fiction',
        content: template.render(
          featured_work: works.featured,
          latest_work: works.latest,
        )
      )
    ]]
  end
end
