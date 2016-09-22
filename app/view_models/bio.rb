require 'gravatar'

class ViewModels::Bio
  def initialize(author)
    @author = author
  end

  def author
    @author
  end

  def author_name
    @author.name
  end

  def animated
    false #TODO: here
  end

  def gravatar_url
    Gravatar.url(author.email)
  end

  def website
    @author.website
  end

  def twitter_username
    @author.twitter_username
  end
end
