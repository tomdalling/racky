require_relative 'common'
require 'expectations'
require 'capybara/dsl'
require 'app'

Capybara.app = App['root_app']

class FeatureTest < Minitest::Test
  include Expectations
  include Capybara::DSL

  def after_teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    super
  end

  def assert_path(path)
    assert_equal path, current_path
  end

  def sign_in!
    visit '/auth/sign_in'
    fill_in 'Username', with: 'admin'
    fill_in 'Password', with: '123'
    click_button 'Sign In'
    assert_path '/'
  end

  alias_method :try_visit, :visit

  def visit(path)
    super(path)
    assert_path(path)
  end

  def assert_page(method, *args)
    msg = "page.#{method}(#{args.map(&:inspect).join(', ')})"
    assert page.send(method, *args), msg
  end
end
