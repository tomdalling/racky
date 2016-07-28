create_table(:works) do
  primary_key :id
  String :title
  Time :featured_at
  Time :published_at #default: Sequel::CURRENT_TIMESTAMP
end
