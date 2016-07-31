require 'sass'

class Controllers::Stylesheet
  def call(env)
    engine = Sass::Engine.new('@import "stylesheet"',
      style: :compressed,
      syntax: :scss,
      load_paths: [App::ROOT.join('app/assets/').realpath],
    )

    [200, {}, [engine.render]]
  end
end
