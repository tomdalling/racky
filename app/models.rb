require 'pigeon/struct'
require 'attrs'

User = Pigeon::Struct.define do
  def_attr :id, coercer: Attrs::PrimaryKey
  def_attr :email, coercer: Attrs.type(String)
  def_attr :name, coercer: Attrs.type(String)
  def_attr :machine_name, coercer: Attrs::MachineName
  def_attr :password_hash, coercer: Attrs.type(String)
end

Work = Pigeon::Struct.define do
  def_attr :id, coercer: Attrs::PrimaryKey
  def_attr :user_id, coercer: Attrs::ForeignKey
  def_attr :title, coercer: Attrs.type(String)
  def_attr :machine_name, coercer: Attrs::MachineName
  def_attr :lif_document, coercer: Attrs.type(String)
  def_attr :featured_at, coercer: Attrs.maybe_type(Time)
  def_attr :published_at, coercer: Attrs.maybe_type(Time)

  def_attr :author, default: nil, coercer: Attrs.maybe_type(User)
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
