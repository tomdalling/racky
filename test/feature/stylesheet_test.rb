require 'feature_test'

class StylesheetTest < FeatureTest
  def test_content
    visit '/css/style.css'
    assert_page_content '.col-md-6' # bootstrap
    assert_page_content '.lif-document' # custom scss
  end
end
