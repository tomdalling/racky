class Endpoints::EditBioForm < RequestHandler
  def run
    render(:edit_bio, user: current_user)
  end
end
