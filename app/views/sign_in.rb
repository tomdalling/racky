class Views::SignIn
  include App::Inject[
    template: 'templates.sign_in',
    layout: 'templates.layout',
  ]

  def render(args={})
    layout.render(
      title: 'Sign In',
      content: template.render(args),
    )
  end
end
