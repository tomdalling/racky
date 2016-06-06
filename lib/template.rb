require 'erb'

class Template
  def self.from_file(path)
    new(File.read(path), path)
  end

  def initialize(erb_string, filename=nil)
    @compiled_source = ERB.new(erb_string).src
    @filename = filename
  end

  def render(context=nil)
    context.instance_eval(@compiled_source, @filename || '(ERB)', 0)
  end

  module CleanBinding
    def self.binding_for_template_context
      yield.instance_eval{ binding }
    end
  end
end
