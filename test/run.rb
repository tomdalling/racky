require 'minitest/autorun'
require 'minitest/pride'
require 'test_helper'

Dir.chdir(File.dirname(__FILE__))
Dir.glob('**/*_test.rb') do |path|
  puts path
  require_relative path
end
