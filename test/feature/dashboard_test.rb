require 'feature_test'

class DashboardTest < FeatureTest
  def test_content
    sign_in!
    visit '/dashboard'

    assert page.has_link? 'Featured Peatured', href: '/@sam/featured_peatured'
    assert page.has_link? 'Latest Baitest', href: '/@sam/latest_baitest'
  end
end
