require 'feature_test'

class BioTest < FeatureTest
  def test_it
    sign_in!

    click_link 'Edit Bio'
    assert_page_content 'Sam Smith', in: '.author-bio'

    fill_in 'Name', with: 'Flippery Fam'
    click_button 'Update Bio'
    assert_page_content 'Flippery Fam', in: '.author-bio'
    refute page.has_content?('Sam Smith')
  end
end
