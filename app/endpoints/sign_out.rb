class Endpoints::SignOut < RequestHandler
  def run
    Authentication.clear(session)
    redirect(HrefFor.homepage)
  end
end
