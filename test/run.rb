require_relative 'test_helper'

Dir.chdir(File.dirname(__FILE__))
Dir.glob('**/*_test.rb') do |path|
  require_relative path
end
