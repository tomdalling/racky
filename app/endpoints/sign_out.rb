class Endpoints::SignOut < RequestHandler
  def run
    session.clear
    redirect('/')
  end
end
