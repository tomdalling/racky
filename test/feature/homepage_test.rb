require 'feature_test'

class HomepageTest < FeatureTest
  def test_content
    visit '/'

    assert page.find('.featured').has_content?('Featured Peatured')
    assert page.find('.latest').has_content?('Latest Baitest')
  end
end
