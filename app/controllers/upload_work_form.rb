require 'view'

class Controllers::UploadWorkForm
  include App::Inject[view: 'templates.upload_work']
  def call(env)
    [
      200,
      {},
      View.render(view),
    ]
  end
end
