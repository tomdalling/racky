require 'feature_test'

class EverythingTest < FeatureTest
  def test_unauthorized_redirect
    try_visit '/'
    assert_path '/auth/sign_in'
  end

  def test_sign_in_failure
    visit '/auth/sign_in'
    fill_in 'Username', with: 'admin'
    fill_in 'Password', with: 'wrong password'
    click_button 'Sign In'

    assert_path '/auth/sign_in'
    assert_page :has_content?, "Username or password was incorrect"
  end

  def test_sign_in_success
    visit '/auth/sign_in'
    fill_in 'Username', with: 'admin'
    fill_in 'Password', with: '123'
    click_button 'Sign In'

    assert_path '/'
    assert_page :has_content?, "you're logged into it now"
  end

  def test_sign_out
    sign_in!
    visit '/'
    click_button 'Sign Out'

    assert_path '/auth/sign_out'
    assert_page :has_content?, 'You have been signed out successfully.'

    # make sure can't access unauthorized endpoints anymore
    try_visit '/'
    assert_path '/auth/sign_in'
  end
end
