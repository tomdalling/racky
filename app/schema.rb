create_table(:works) do
  primary_key :id
  foreign_key :user_id, :users
  String :title
  String :machine_name
  String :lif_document
  Time :featured_at
  Time :published_at #default: Sequel::CURRENT_TIMESTAMP

  index [:user_id, :machine_name], unique: true
end

create_table(:users) do
  primary_key :id
  String :email
  String :name
  String :machine_name, unique: true
  String :password_hash
end
