class Views::Dashboard
  include App::Inject[
    template: 'templates.dashboard',
    layout: 'templates.layout',
  ]

  def render(current_user)
    layout.render(
      title: 'Dashboard',
      current_user: current_user,
      content: template.render
    )
  end
end
