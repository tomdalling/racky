require 'unit_test'
require 'template'

class TemplateTest < UnitTest
  def test_typical_template
    template = Template.new(<<~EOS)
      ---
      title: Whatever
      layout: default
      ---

      Hello, <%= name %>!
    EOS
    expect(template.frontmatter) == { 'title' => 'Whatever', 'layout' => 'default' }
    result = template.render(name: '"World>')
    expect(result.strip) == 'Hello, &quot;World&gt;!'
  end

  def test_no_frontmatter
    template = Template.new('No frontmatter')
    expect(template.frontmatter) == {}
    expect(template.render) == 'No frontmatter'
  end

  def test_errors
    tpl = <<~EOS
      This is line one.
      This is <%= unicorn %>.
    EOS
    template = Template.new(tpl, 'lib/whatever.rb')

    ex = assert_raises { template.render }

    expect(ex).is_a NameError
    expect(ex.message).includes 'unicorn'
    expect(ex.backtrace.first).starts_with 'lib/whatever.rb:2'
  end
end
