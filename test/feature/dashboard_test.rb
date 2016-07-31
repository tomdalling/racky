require 'feature_test'

class DashboardTest < FeatureTest
  def test_content
    user = sign_in!
    create!(works: [
      { user_id: user.id, title: 'Mahagaba', machine_name: 'Mahagaba' },
      { user_id: user.id, title: 'Mahuggable', machine_name: 'Mahuggable' },
      { user_id: user.id, title: 'Muhringus', machine_name: 'Muhringus' },
    ])

    visit '/dashboard'

    assert page.has_link? 'Mahagaba', href: '/@feature_test_user/Mahagaba'
    assert page.has_link? 'Mahuggable', href: '/@feature_test_user/Mahuggable'
    assert page.has_link? 'Muhringus', href: '/@feature_test_user/Muhringus'
  end
end
