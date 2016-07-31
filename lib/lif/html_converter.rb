require 'erb'

module LIF
  class HTMLConverter
    def self.convert(*args)
      new(*args).send(:html)
    end

    private

    def initialize(lif_document)
      @document = lif_document
      @output = ""
    end

    def html
      # TODO: Catch indented paragraphs here somewhere
      write_document(@document)
      @output
    end

    def write_document(document)
      document.scenes.each_with_index do |scene, idx|
        write('<hr />') if idx > 0
        write_scene(scene)
      end
    end

    def write_scene(scene)
      is_followon = false
      scene.paragraphs.each_with_index do |para, idx|
        unless empty_paragraph?(para)
          write_paragraph(para, is_followon)
          is_followon = !para.style.indented?
        end
      end
    end

    def write_paragraph(para, is_followon)
      write('<p', paragraph_attributes(para.style, is_followon), '>')
      para.runs.each { |r| write_run(r) }
      write('</p>')
    end

    def paragraph_attributes(style, is_followon)
      classes = [
        [style.indented?, 'indent'],
        [is_followon && !style.indented?, 'fl-indent'],
      ].select(&:first).map(&:last)

      classes.empty? ? '' : %{ class="#{classes.join(' ')}"}
    end

    def write_run(run)
      attrs = run_attrs(run.style)
      run.lines.each_with_index do |line, idx|
        if line.is_a?(LIF::LineBreak)
          write('<br />')
        else
          write('<span ', attrs, '>') if attrs
          write_text(line)
          write('</span>') if attrs
        end
      end
    end

    def run_attrs(style)
      classes = [
        [style.bold?, 'b'],
        [style.italic?, 'i']
      ].select(&:first).map(&:last)

      classes.any? ? %{class="#{classes.join(' ')}"} : nil
    end

    def empty_paragraph?(para)
      para.runs.size == 0
    end

    def write_text(t)
      write(ERB::Util.html_escape(t))
    end

    def write(*outputs)
      outputs.each{ |o| @output << o }
    end

  end
end

