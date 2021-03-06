require 'erubis'
require 'ostruct'
require 'yaml'

class Template
  FRONTMATTER_REGEX = %r{
    \A---\n  # first line must be three hyphens
    .*       # anything can go here
    ^---\n   # another line with three hyphens
  }mx

  attr_reader :frontmatter

  def initialize(raw_source, filename='(ERB)')
    @frontmatter, erb = self.class.extract_frontmatter(raw_source)
    @erb = Erubis::EscapedEruby.new(erb, filename: filename)
  end

  def render(context=nil)
    # don't pass hashes directly into the template, because erubis
    # converts them to some wierd Eribus::Context object
    @erb.evaluate(context.is_a?(Hash) ? Args.new(context) : context)
  end

  def self.extract_frontmatter(source)
    match = FRONTMATTER_REGEX.match(source)
    if match
      frontmatter = match.to_s
      [YAML.load(frontmatter), source[frontmatter.length..-1]]
    else
      [{}, source]
    end
  end

  private

    class Args
      def initialize(vars)
        @vars = vars
      end

      def method_missing(symbol, *args)
        if @vars.has_key?(symbol) && args.empty?
          @vars.fetch(symbol)
        else
          super
        end
      end

      def respond_to?(sym, include_all=false)
        @vars.has_key?(sym) || super
      end
    end
end
