class Page
  def initialize(template_resolver)
    @template_resolver = template_resolver
  end

  def render(template_name, args={})
    template = @template_resolver[template_name]

    layout_name = template.frontmatter.fetch('layout', 'layout')
    layout = @template_resolver[layout_name]
    layout.render(args.merge(
      title: template.frontmatter['title'],
      content: template.render(args),
    ))
  end
end
