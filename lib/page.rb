class Page
  def initialize(template_resolver)
    @template_resolver = template_resolver
  end

  def render(template_name, args={}, view_model_class=nil)
    template = @template_resolver[template_name]
    context = view_model_class ? view_model_class.new(args) : args

    layout_name = template.frontmatter.fetch('layout', 'layout')
    layout = @template_resolver[layout_name]
    layout.render(args.merge(
      title: template.frontmatter['title'],
      content: template.render(context),
    ))
  end

  def response(template_name, args={})
    [200, {}, [render(template_name, args)]]
  end
end
