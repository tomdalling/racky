require 'values'

# Litmal Interchange Format
module LIF
  LineBreak = Class.new
  LINE_BREAK = LineBreak.new

  Document = Value.new(:scenes)

  Scene = Value.new(:paragraphs)

  Paragraph = Value.new(:runs, :style) do
    def text; runs.map(&:text).join; end
  end

  ParagraphStyle = Value.new(:indented, :first_line_indented, :based_on) do
    alias_method :indented?, :indented
    alias_method :first_line_indented?, :first_line_indented
  end

  Run = Value.new(:lines, :style) do
    def text; lines.join; end
  end

  RunStyle = Value.new(:bold, :italic) do
    alias_method :bold?, :bold
    alias_method :italic?, :italic
  end
end

require 'lif/html_converter'
require 'lif/docx_parser'
require 'lif/json'
