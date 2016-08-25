require 'lif'

class WorkDecorator
  def initialize(work)
    @work = work
  end

  def title
    @work.title
  end

  def author
    @work.author
  end

  def document_html
    @document_html ||= begin
      document ? LIF::HTMLConverter.convert(document) : ""
    end
  end

  def blurb_html
    @blurb_html ||= begin
      first_para = document.scenes.first.paragraphs.first
      blurb_doc = document.with(scenes: [
        LIF::Scene.with(paragraphs: [first_para]),
      ])
      LIF::HTMLConverter.convert(blurb_doc)
    end
  end

  def path
    raise "Work must have author preloaded" unless @work.author
    "/@#{@work.author.machine_name}/#{@work.machine_name}"
  end

  def document
    @document ||= begin
      if @work.lif_document
        LIF::JSON::Parser.parse(@work.lif_document)
      else
        nil
      end
    end
  end
end
