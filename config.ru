$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))
require 'rack'
require 'app'

use Rack::Session::Cookie, {
  key: Session::COOKIE_NAME,
  secret: 'change_me',
  coder: Rack::Session::Cookie::Base64::ZipJSON.new,
}

run App.new
