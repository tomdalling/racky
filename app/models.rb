require 'pigeon/struct'

Work = Pigeon::Struct.define do
  def_attr :id
  def_attr :user_id
  def_attr :title
  def_attr :machine_name
  def_attr :lif_document
  def_attr :featured_at
  def_attr :published_at

  def_attr :author, default: nil
end

User = Pigeon::Struct.define do
  def_attr :id
  def_attr :email
  def_attr :name
  def_attr :machine_name
  def_attr :password_hash
end

#TODO: probably put all these methods elsewhere
class Work
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
