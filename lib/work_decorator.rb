require 'lif'

class WorkDecorator < SimpleDelegator
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

  def document
    @document ||= begin
      if lif_document
        LIF::JSON::Parser.parse(lif_document)
      else
        nil
      end
    end
  end

  def self.to_proc
    ->(work) { new(work) }
  end
end
