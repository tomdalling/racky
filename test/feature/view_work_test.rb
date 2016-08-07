require 'feature_test'

class ViewWorkTest < FeatureTest
  def test_it
    visit '/@sam/featured_peatured'
    expect(page.status_code) == 200
    assert_page_content 'This is a very short document.'
  end
end
