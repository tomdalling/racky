require_relative 'common'
require 'expectations'
require 'capybara/dsl'
require 'app'
require 'password'
require 'fixture_dsl'
require 'config'


Capybara.app = begin
  app = App.new(Config.new(
    'DB_CONNECTION_STR' => 'sqlite::memory',
  ))

  dsl = FixtureDSL.new
  path = 'test/fixtures/db.rb'
  dsl.instance_eval(File.read(path), path, 1)

  db = app.container.resolve('db')
  dsl.records_by_table.each do |table, records|
    records.each do |attrs|
      db[table].insert(attrs)
    end
  end

  app
end


class FeatureTest < Minitest::Test
  include Expectations
  include Capybara::DSL

  def before_setup
    db.run('BEGIN TRANSACTION')
    super
  end

  def after_teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    super
    db.run('ROLLBACK')
  end

  def assert_path(path, msg=nil)
    assert_equal path, current_path, msg
  end

  def sign_in!
    visit '/auth/sign_in'
    fill_in 'Email', with: 'sam@example.com'
    fill_in 'Password', with: 'slippery sam'
    click_button 'Sign In'

    assert_path '/dashboard'

    nil
  end

  def resolve(key)
    Capybara.app.container[key]
  end

  def db
    resolve('db')
  end

  def flesh_out(table, attrs)
    if table == :works && !attrs[:lif_document]
      attrs.merge(lif_document: lif_document_fixture)
    else
      attrs
    end
  end

  def lif_document_fixture
    @_lif_document_fixture ||= begin
      lif = LIF::DocxParser.parse('test/fixtures/mahagaba.docx')
      LIF::JSON::Converter.convert(lif)
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

  def assert_page_content(content, options={})
    selector = options[:in]
    element = selector ? page.find(selector) : page
    assert element.has_content?(content), "assert_page_content #{content.inspect}, #{options.inspect}"
  end
end
