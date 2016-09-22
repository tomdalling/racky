require 'models'
require 'lif'

class Commands::CreateWork
  include DefDeps['db']

  def call(attrs, author)
    attrs = {
      title: attrs.fetch(:title),
      machine_name: Work.machine_name(attrs.fetch(:title)),
      user_id: author.id,
      lif_document: lif_json_for_docx_file(attrs.fetch(:file).fetch(:tempfile)),
      published_at: Time.now, #TODO: don't auto-publish new documents
      featured_at: nil,
    }

    id = db[:works].insert(attrs)

    Work.new(attrs.merge(id: id, author: author))
  end

  def lif_json_for_docx_file(docx_file)
    lif_document = LIF::DocxParser.parse(docx_file.path)
    LIF::JSON::Converter.convert(lif_document)
  end
end
