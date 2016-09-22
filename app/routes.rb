require 'enforce_authenticated'

middleware Rack::Session::Cookie,
  key: Session::COOKIE_NAME,
  secret: '#TODO: change_me',
  coder: Rack::Session::Cookie::Base64::ZipJSON.new

middleware Authentication, _resolve('queries/user')

get  '/' => :home
get  '/css/style.css' => :stylesheet
get  '/@:user/:work' => :view_work

namespace '/auth' do
  get  '/sign_in' => :sign_in_form
  post '/sign_in' => :sign_in
  post '/sign_out' => :sign_out
end

group :authentication_required do
  middleware EnforceAuthenticated

  get  '/dashboard' => :dashboard
  get  '/works/upload' => :upload_work_form
  post '/works/upload' => :upload_work
  get  '/bio' => :edit_bio_form
  post '/bio' => :edit_bio
end

always :not_found
