require 'unit_test'
require 'lif'

class LIFTest < UnitTest

  def test_docx_parser
    refute_nil doc
    refute_empty doc.scenes
  end

  def test_html_converter
    html = LIF::HTMLConverter.convert(doc)
    assert html.include?('pretty cool guys'), 'Some body text missing'
  end

  def test_json_converter_and_parser
    json = LIF::JSON::Converter.convert(doc)
    assert_kind_of String, json

    reconstructed = LIF::JSON::Parser.parse(json)
    assert_equal reconstructed, doc
  end

  def doc
    self.class.doc
  end

  def self.doc
    @_doc ||= LIF::DocxParser.parse('test/data/mr_sweetly.docx')
  end

end
