require 'ostruct'
require 'unit_test'
require 'work_decorator'

class WorkDecoratorTest < UnitTest
  def test_it
    bob = OpenStruct.new(machine_name: 'bob')
    doc = LIF::DocxParser.parse('test/fixtures/short.docx')
    lif_json = LIF::JSON::Converter.convert(doc)
    work = OpenStruct.new(title: 'Hi There', machine_name: 'hi_there', author: bob, lif_document: lif_json)
    decorator = WorkDecorator.new(work)

    expect(decorator.title) == 'Hi There'
    expect(decorator.document_html) == '<p>This is a very short document.</p>'
    expect(decorator.blurb_html) == '<p>This is a very short document.</p>'
    expect(decorator.path) == '/@bob/hi_there'
  end
end
