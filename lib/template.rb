require 'erubis'
require 'ostruct'

class Template
  def initialize(raw_source, filename='(ERB)')
    @erb = Erubis::EscapedEruby.new(raw_source, filename: filename)
  end

  def render(context=nil)
    # don't pass hashes directly into the template, because erubis
    # converts them to some wierd Eribus::Context object
    @erb.evaluate(context.is_a?(Hash) ? OpenStruct.new(context) : context)
  end

  #TODO: this should probably be moved to a separate class
  TEMPLATE_DIR = 'templates'
  def self.get(name)
    name = name.to_sym

    @cache ||= {}
    @cache.fetch(name) do
      path = File.join(TEMPLATE_DIR, "#{name}.erb")
      raw_source = File.read(path)
      @cache[name] = new(raw_source, path)
    end
  end
end
