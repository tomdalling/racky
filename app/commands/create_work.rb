require 'work'
require 'lif'

class Commands::CreateWork
  include DefDeps['db']

  def call(params, user_id)
    attrs = {
      title: params.fetch('title'),
      machine_name: Work.machine_name(params.fetch('title')),
      user_id: user_id,
      lif_document: lif_json_for_docx_file(params.fetch('file').fetch(:tempfile)),
      published_at: Time.now, #TODO: don't auto-publish new documents
    }

    id = db[:works].insert(attrs)

    OpenStruct.new(attrs.merge(id: id))
  end

  def lif_json_for_docx_file(docx_file)
    lif_document = LIF::DocxParser.parse(docx_file.path)
    LIF::JSON::Converter.convert(lif_document)
  end
end
