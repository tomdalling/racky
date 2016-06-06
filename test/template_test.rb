require 'template'

class TemplateTest < Minitest::Test
  def test_rendering
    template = Template.new("Hello, <%= self %>!")
    assert_equal 'Hello, World!', template.render('World')
  end

  def test_errors
    tpl = <<~EOS
      This is line one.
      This is <%= unicorn %>.
    EOS
    template = Template.new(tpl, 'lib/whatever.rb')

    ex = assert_raises { template.render }
    assert_kind_of NameError, ex
    assert_includes ex.message, 'unicorn'
    assert_send [ex.backtrace.first, :start_with?, 'lib/whatever.rb:2']
  end
end
