user(
  id: 1,
  email: 'sam@example.com',
  password_hash: password_hash('slippery sam'),
  name: 'Sam Smith',
  machine_name: 'sam',
  website: 'http://sam.example.com/',
  twitter_username: 'sam',
)

work title: 'Old Mold', published_at: Time.now - 100

work(
  title: 'Featured Peatured',
  machine_name: 'featured_peatured',
  user_id: 1,
  published_at: Time.now - 5,
  featured_at: Time.now,
  lif_document: lif_json('short.docx'),
)

work(
  title: 'Latest Baitest',
  machine_name: 'latest_baitest',
  user_id: 1,
  published_at: Time.now + 5,
  lif_document: lif_json('short.docx'),
)
