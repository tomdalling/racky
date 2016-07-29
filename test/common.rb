ENV['RACK_ENV'] = 'test'

ROOT_DIR = File.expand_path('../..', __FILE__)

Dir.chdir(ROOT_DIR)

$LOAD_PATH.unshift(File.expand_path('test', ROOT_DIR))
$LOAD_PATH.unshift(File.expand_path('lib', ROOT_DIR))

require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
