require 'feature_test'

class HomepageTest < FeatureTest
  def test_content
    create_records!(works: [
      { title: 'Old Mold', featured_at: Time.now - 5 },
      { title: 'Featured Peatured', featured_at: Time.now },
      { title: 'Latest Baitest', published_at: Time.now + 7 },
    ])

    visit '/'

    assert page.find('.featured').has_content?('Featured Peatured')
    assert page.find('.latest').has_content?('Latest Baitest')
  end
end
