require 'endpoint'

class Endpoints::SignOut < Endpoint
  def run
    session.clear
    redirect('/')
  end
end
