require 'endpoint'

class Endpoints::UploadWork < Endpoint
  dependencies create_work: 'commands/create_work'
  params {{
    title: String,
    file: any,
  }}

  def run
    work = create_work.call(params, current_user)
    redirect(WorkDecorator.new(work).path)
  end
end
