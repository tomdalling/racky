require 'feature_test'

class WorksTest < FeatureTest
  def setup
    sign_in!
  end

  def test_upload
    click_link 'Upload'
    fill_in 'Title', with: 'Mahagaba'
    attach_file 'Word Document', 'test/data/mahagaba.docx'
    click_button 'Upload'

    assert_path '/@feature_test_user/mahagaba'
    assert_page_content('Mahagaba', in: 'h1')
  end
end
