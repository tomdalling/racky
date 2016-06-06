require 'template'

class TemplateTest < Test
  def test_rendering
    template = Template.new("Hello, <%= self %>!")
    result = template.render('World')

    expect result, :==, 'Hello, World!'
  end

  def test_errors
    tpl = <<~EOS
      This is line one.
      This is <%= unicorn %>.
    EOS
    template = Template.new(tpl, 'lib/whatever.rb')

    ex = assert_raises { template.render }

    expect ex, :is_a, NameError
    expect ex.message, :includes, 'unicorn'
    expect ex.backtrace.first, :starts_with, 'lib/whatever.rb:2'
  end
end
