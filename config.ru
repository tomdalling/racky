$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))
require 'rack'
require 'app'

run App['root_app']
