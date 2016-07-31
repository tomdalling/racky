require_relative 'common'
require 'expectations'
require 'capybara/dsl'
require 'app'
require 'password'

Capybara.app = App

class FeatureTest < Minitest::Test
  include Expectations
  include Capybara::DSL

  def after_teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    super
  end

  def assert_path(path, msg=nil)
    assert_equal path, current_path, msg
  end

  def sign_in!
    create!(users: {
      name: 'Feature Test User',
      machine_name: 'feature_test_user',
      email: 'feature_test_user@example.com',
      password_hash: Password.hashed('i love feature tests'),
    })

    visit '/auth/sign_in'
    fill_in 'Email', with: 'feature_test_user@example.com'
    fill_in 'Password', with: 'i love feature tests'
    click_button 'Sign In'

    assert_path '/dashboard'
  end

  def db
    App['db']
  end

  def create!(records)
    records.each do |table, attr_list|
      (attr_list.is_a?(Array) ? attr_list : [attr_list]).each do |attrs|
        db[table].insert(attrs)
      end
    end
  end

  alias_method :try_visit, :visit

  def visit(path)
    super(path)
    assert_path(path, "Failed to visit path: #{path}")
  end

  def assert_page(method, *args)
    msg = "Failed: page.#{method}(#{args.map(&:inspect).join(', ')})"
    assert page.send(method, *args), msg
  end

  def assert_page_content(content, options)
    selector = options[:in]
    element = selector ? page.find(selector) : page
    assert element.has_content?(content)
  end
end
