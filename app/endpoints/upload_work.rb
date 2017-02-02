class Endpoints::UploadWork < RequestHandler
  dependencies create_work: 'commands/create_work'
  params {{
    title: _String,
    file: anything,
  }}

  def run
    work = create_work.(params, current_user)
    redirect(HrefFor.work(work))
  end
end
