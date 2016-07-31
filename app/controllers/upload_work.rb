require 'authentication'

class Controllers::UploadWork
  include App::Inject['commands.create_work']

  def call(env)
    current_user = Authentication.get(env)
    params = Params.get(env)
    work = create_work.call(params, current_user.id)
    [303, { 'Location' => "/@#{current_user.machine_name}/#{work.machine_name}" }, []]
  end
end
