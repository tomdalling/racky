require 'inflecto'

#TODO: this all needs refactoring
class Page
  def initialize(template_resolver)
    @template_resolver = template_resolver
  end

  def render(template_name, args=[], common_vars={})
    template = @template_resolver[template_name]
    context = Context.new(self, template, args, common_vars)
    body = template.render(context)

    layout_name = template.frontmatter.fetch('layout', 'layout')
    layout = @template_resolver[layout_name]
    title = template.frontmatter.fetch('title') do
      raise ArgumentError, "Template #{template_name.inspect} is missing a title in the frontmatter"
    end

    layout.render(common_vars.merge(
      title: interpolate(context, title),
      content: body,
    ))
  end

  def render_partial(template_name, args=[], common_vars={})
    template = @template_resolver[template_name]
    context = Context.new(self, template, args, common_vars)
    template.render(context)
  end

  def interpolate(context, format_str)
    format_str.gsub(/\#\{[^\}]+}/) do |match|
      code = match[2..-2]
      context.instance_eval(code).to_s
    end
  end

  def response(template_name, args={})
    [200, {}, [render(template_name, args)]]
  end

  class Context
    def initialize(page, template, args, common_vars)
      @page = page
      @common_vars = common_vars

      @vars = common_vars
      if args.size == 1 && args.first.is_a?(Hash)
        @vars = @vars.merge(args.first)
      end

      vm_name = template.frontmatter['view_model']
      @view_model = if vm_name
        require vm_name
        klass_name = Inflecto.camelize(vm_name)
        Inflecto.constantize(klass_name).new(*args)
      else
        nil
      end
    end

    def render(template_name, *args)
      @page.render_partial(template_name, args, @common_vars)
    end

    def method_missing(sym, *args, &block)
      if args.empty? && @vars.has_key?(sym)
        @vars.fetch(sym)
      elsif @view_model && @view_model.respond_to?(sym)
        @view_model.send(sym, *args, &block)
      else
        super
      end
    end

    def respond_to?(sym, include_all=false)
      super || @vars.has_key?(sym) || (@view_model && @view_model.respond_to?(sym))
    end
  end
end
