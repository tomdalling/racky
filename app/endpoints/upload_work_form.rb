require 'endpoint'

class Endpoints::UploadWorkForm < Endpoint
  def run
    render(:upload_work)
  end
end
