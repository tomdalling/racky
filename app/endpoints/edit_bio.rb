class Endpoints::EditBio < RequestHandler
  dependencies update_bio: 'commands/update_bio'

  params {{
    name: _String,
    website: maybe(_String),
    twitter_username: maybe(_String),
  }}

  def run
    update_bio.call(params, current_user)
    redirect('/bio')
  end
end
