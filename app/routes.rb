require 'enforce_authenticated'

middleware Rack::Session::Cookie,
  key: Session::COOKIE_NAME,
  secret: '#TODO: change_me',
  coder: Rack::Session::Cookie::Base64::ZipJSON.new

middleware Authentication

get  '/' => :home

namespace '/auth' do
  get  '/sign_in' => :sign_in_form
  post '/sign_in' => :sign_in
  post '/sign_out' => :sign_out
end

group do
  middleware EnforceAuthenticated

  get  '/dashboard' => :dashboard
end

always :not_found
