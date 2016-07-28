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
end
