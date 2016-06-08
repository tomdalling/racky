require 'erubis'

class Template
  def initialize(raw_source, filename='(ERB)')
    @erb = Erubis::EscapedEruby.new(raw_source, filename: filename)
  end

  def render(context=nil)
    @erb.evaluate(context)
  end

  #TODO: this should probably be moved to a separate class
  TEMPLATE_DIR = 'templates'
  def self.render(name, context)
    name = name.to_sym

    @cache ||= {}
    template = @cache.fetch(name) do
      path = File.join(TEMPLATE_DIR, "#{name}.erb")
      raw_source = File.read(path)
      new(raw_source, path)
    end

    template.render(context)
  end
end
