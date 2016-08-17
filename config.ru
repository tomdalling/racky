require 'rack'

$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path('app', File.dirname(__FILE__)))
require 'app'
require'config'

config = Config.from_file(App::ROOT.join('config.yml'))
run App.new(config)
