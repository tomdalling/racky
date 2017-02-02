require 'endpoint'

class Endpoints::UploadWork < Endpoint
  dependencies create_work: 'commands/create_work'
  params {{
    title: _String,
    file: anything,
  }}

  def run
    work = create_work.call(params, current_user)
    redirect(WorkDecorator.new(work).path)
  end
end
