require 'feature_test'

class ViewWorkTest < FeatureTest
  def test_it
    visit '/@sam/featured_peatured'
    expect(page.status_code) == 200
    assert_page_content 'This is a very short document.'
    expect(page.title).includes('Featured Peatured', 'Sam Smith')
    assert_page_content 'Sam Smith'
  end
end
