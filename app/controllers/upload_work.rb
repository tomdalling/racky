class Controllers::UploadWork
  def call(env)
    [303, { 'Location' => '/@feature_test_user/mahagaba' }, []]
  end
end
