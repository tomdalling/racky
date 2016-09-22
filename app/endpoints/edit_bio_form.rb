require 'endpoint'

class Endpoints::EditBioForm < Endpoint
  def run
    render(:edit_bio, user: current_user)
  end
end
