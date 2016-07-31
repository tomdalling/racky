require 'feature_test'
require 'password'

class AuthenticationTest < FeatureTest
  def setup
    create!(users: {
      name: 'Sam Smith',
      email: 'sam@example.com',
      password_hash: Password.hashed('slippery sam'),
    })
  end

  def test_successful_sign_in
    visit '/'
    click_link 'Sign In'
    assert_path '/auth/sign_in'
    fill_in 'Email', with: 'sam@example.com'
    fill_in 'Password', with: 'slippery sam'
    click_button 'Sign In'

    assert_path '/dashboard'
    assert_page :has_content?, 'Sam Smith'
  end

  def test_failed_sign_in
    visit '/auth/sign_in'

    # incorrect email
    fill_in 'Email', with: 'wrong@example.com'
    fill_in 'Password', with: 'slippery sam'
    click_button 'Sign In'
    assert_path '/auth/sign_in'
    assert_page :has_content?, 'Email or password was incorrect'

    # incorrect password
    fill_in 'Email', with: 'sam@example.com'
    fill_in 'Password', with: 'wrong password'
    click_button 'Sign In'
    assert_path '/auth/sign_in'
    assert_page :has_content?, 'Email or password was incorrect'
  end

  def test_already_signed_in
    sign_in!
    try_visit '/auth/sign_in'
    assert_path '/dashboard'
  end

  def test_unauthenticated_redirect
    try_visit '/dashboard'
    assert_path '/auth/sign_in'
    assert_page :has_content?, 'You must be signed in to view that page'
  end

  def test_sign_out
    sign_in!
    assert_path '/dashboard'

    click_button 'Sign Out'
    assert_path '/'

    try_visit '/dashboard'
    assert_path '/auth/sign_in'
  end
end
