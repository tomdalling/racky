module Work
  def self.machine_name(title)
    title.gsub(/[^a-zA-Z0-9\-]/, '_').squeeze('_')
  end

  def self.path(user, work)
    "/@#{user.machine_name}/#{work.machine_name}"
  end

  def self.visible_to_user?(work, user)
    if work.published_at
      true # published works are visible to everyone
    elsif user && user.id == work.user_id
      true # works are visible to their creator
    else
      false
    end
  end
end
