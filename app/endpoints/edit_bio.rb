require 'endpoint'

class Endpoints::EditBio < Endpoint
  dependencies update_bio: 'commands/update_bio'

  params {{
    name: String,
    website: maybe(String),
    twitter_username: maybe(String),
  }}

  def run
    update_bio.call(params, current_user)
    redirect('/bio')
  end
end
