class Controllers::Work
  include App::Inject[view: 'templates.work']

  def call(env)
    params = Params.get(env)
    [200, {}, [View.render(view)]]
  end
end
