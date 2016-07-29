module View
  def self.render(template, args={})
    layout_name = template.frontmatter['layout'] || 'layout'
    #TODO: I think App[] is allocating. It shouldn't be, though.
    layout = App["templates.#{layout_name}"]
    layout.render(args.merge(
      title: template.frontmatter['title'],
      content: template.render(args),
    ))
  end
end
