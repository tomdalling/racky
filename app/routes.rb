middleware Rack::Session::Cookie,
  key: Session::COOKIE_NAME,
  secret: '#TODO: change_me',
  coder: Rack::Session::Cookie::Base64::ZipJSON.new

get  '/' => :home
#always :not_found
