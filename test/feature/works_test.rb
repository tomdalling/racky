require 'feature_test'

class WorksTest < FeatureTest
  def setup
    sign_in!
  end

  def test_upload
    click_link 'Upload'
    fill_in 'Title', with: 'Mahagaba'
    attach_file 'Word Document', 'test/fixtures/mahagaba.docx'
    click_button 'Upload'

    assert_path '/@sam/Mahagaba'
    expect(page.status_code) == 200
    assert_page_content 'Mahagaba', in: 'h1'
    assert_page_content 'Mahagaba was a white clydesdale'
  end
end
