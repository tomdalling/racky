require 'feature_test'

class HomepageTest < FeatureTest
  def test_content
    visit '/'

    featured = page.find('.featured')
    assert featured.has_content?('Featured Peatured')
    assert featured.has_link?('Continue reading', href: '/@sam/featured_peatured')

    latest = page.find('.latest')
    assert latest.has_content?('Latest Baitest')
    assert latest.has_link?('Continue reading', href: '/@sam/latest_baitest')
  end
end
