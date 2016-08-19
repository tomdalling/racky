require 'endpoint'

class Endpoints::UploadWork < Endpoint
  dependencies create_work: 'commands/create_work'

  def run
    work = create_work.call(params, current_user)
    redirect(WorkDecorator.new(work).path)
  end
end
