class Controllers::UploadWorkForm
  include DefDeps[:page]

  def call(env)
    [
      200,
      {},
      [page.render('upload_work')],
    ]
  end
end
