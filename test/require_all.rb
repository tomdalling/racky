require_relative 'common'

Dir.glob('test/**/*_test.rb') do |path|
  # Hot damn Ruby's path manipulation sucks
  require path[0..-4][5..-1]
end
