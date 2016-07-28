require 'feature_test'

class HomepageTest < FeatureTest
  def test_content
    App['repos.work'].create([
      { title: 'Featured Peatured', featured_at: Time.now },
      { title: 'Latest Baitest' },
    ])

    visit '/'

    assert page.find('.featured').has_content?('Featured Peatured')
    assert page.find('.latest').has_content?('Latest Baitest')
  end
end
