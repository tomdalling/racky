require 'ox'
require 'zip'

module LIF
  class DocxParser
    def self.parse(file_path)
      new(file_path).send(:lif_document)
    end

    def self.extract_xml(file_path)
      parser = new(file_path)
      Ox.dump(parser.send(:word_document))
    end

    private

    def initialize(file_path)
      @file_path = file_path
    end

    def lif_document
      LIF::Document.with(scenes: lif_scenes)
    end

    def lif_scenes
      lif_paragraphs
        .slice_before{ |p| scene_break_paragraph?(p) }
        .map{ |ps| strip_scene_paragraphs(ps) }
        .map{ |ps| LIF::Scene.with(paragraphs: ps) }
    end

    def strip_scene_paragraphs(paragraphs)
      paragraphs
        .drop_while{ |p| strippable_paragraph?(p) }
        .reverse
        .drop_while{ |p| strippable_paragraph?(p) }
        .reverse
    end

    def strippable_paragraph?(para)
      scene_break_paragraph?(para) || empty_paragraph?(para)
    end

    def scene_break_paragraph?(para)
      # all chars are astrisks, minimum of three chars
      para.text.strip =~ /\A\*{3,}\z/
    end

    def empty_paragraph?(para)
      para.runs.all?{ |r| r.text.strip.length == 0 }
    end

    def lif_paragraphs
      # TODO: account for line breaks and indenting
      @paragraphs ||= word_document.locate('w:document/w:body/w:p').map do |p_node|
        LIF::Paragraph.with(
          style: flatten_style_inheritance(paragraph_style(p_node)),
          runs: lif_runs(p_node),
        )
      end
    end

    def paragraph_style(ppr_parent_node)
      ppr_node = ppr_parent_node.locate('w:pPr').first
      wind_node = ppr_node.locate('w:ind').first
      basedon_node = ppr_parent_node.locate('w:basedOn').first
      LIF::ParagraphStyle.with(
        indented: positive_value?(wind_node, ['w:left', 'w:start']),
        first_line_indented: positive_value?(wind_node, ['w:firstLine']),
        based_on: basedon_node ?
          basedon_node['w:val'] :
          ppr_node.locate('w:pStyle/@w:val').first
      )
    end

    # returns:
    #   nil, if no value is found
    #   false, if the value is found, but is not position
    #   true, if the value is found, and is positive
    def positive_value?(node, attributes)
      if node
        attributes.each do |attr|
          value = node[attr]
          return value ? Float(value) > 0.0 : nil
        end
      end

      nil
    end

    def lif_runs(p_node)
      para_style = LIF::RunStyle.with(
        bold: p_node.locate('w:pPr/w:rPr/w:b').size > 0,
        italic: p_node.locate('w:pPr/w:rPr/w:i').size > 0,
      )

      runs = p_node
        .locate('w:r')
        .map { |run| lif_run(run, para_style) }
        .compact

      join_similar_runs(runs)
    end

    def lif_run(run, para_style)
      bold_nodes = run.locate('w:rPr/w:b')
      italic_nodes = run.locate('w:rPr/w:i')

      LIF::Run.with(
        lines: run_lines(run),
        style: LIF::RunStyle.with(
          bold: para_style.bold || (bold_nodes.size > 0),
          italic: para_style.italic || (italic_nodes.size > 0),
        )
      )
    end

    def run_lines(run)
      lines = run.nodes.map { |n| line(n) }
      compress_run_lines(lines)
    end

    def line(run_node)
      case run_node.name
      when 'w:t' then run_node.text
      when 'w:br' then LIF::LINE_BREAK
      else nil
      end
    end

    def compress_run_lines(lines)
      compressed_lines = []

      lines.each do |l|
        case l
        when LIF::LineBreak
          #line breaks are separate elements
          compressed_lines << l
        when String
          if compressed_lines[-1].is_a?(String)
            #if the last line is also a string, join them
            compressed_lines[-1] += l
          else
            #if the last line was a line break, this line must be a separate element
            compressed_lines << l
          end
        when nil
          #just ignore any nils
        else
          fail("Unrecognized type of run line: #{l}")
        end
      end

      compressed_lines
    end

    def file_path
      @file_path
    end

    def style_named(style_id)
      return nil unless style_id

      style_node = styles_document.locate('w:styles/w:style').find do |node|
        node['w:styleId'] == style_id && node['w:type'] == 'paragraph'
      end

      style_node ? paragraph_style(style_node) : nil
    end

    def word_document
      load_docx_xml!
      @word_document
    end

    def styles_document
      # <w:styles ...>
      #   <w:style w:type="paragraph" w:styleId="Body">
      #     <w:basedOn w:val="Underline"/>
      #     <w:pPr>
      #       <w:ind w:left="0" w:right="0" w:firstLine="567"/>

      load_docx_xml!
      @styles_document
    end

    def load_docx_xml!
      return if @word_document

      Zip::File.open(file_path) do |zip|
        @word_document = Ox.parse(zip.read('word/document.xml'))
        @styles_document = Ox.parse(zip.read('word/styles.xml'))
      end
    end

    def flatten_style_inheritance(style)
      inheritance_chain = [style]
      while parent = style_named(inheritance_chain.last.based_on)
        inheritance_chain << parent
      end
      merge_paragraph_styles(inheritance_chain.reverse)
    end

    def merge_paragraph_styles(styles)
      ParagraphStyle.with(
        styles
          .flat_map(&:to_a)
          .reject{ |(attr, value)| value.nil? }
          .reduce({}){ |accum, (attr, value)| accum[attr] = value; accum }
      )
    end

    def join_similar_runs(runs)
      runs
        .slice_when { |left, right| left.style != right.style }
        .map do |similar_runs|
          if similar_runs.size == 1
            similar_runs.first
          else
            LIF::Run.with(
              style: similar_runs.first.style,
              lines: compress_run_lines(similar_runs.flat_map(&:lines)),
            )
          end
        end
    end

  end
end

