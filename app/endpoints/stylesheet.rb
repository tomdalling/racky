require 'sass'

# TODO: delete this and switch to webpack
class Endpoints::Stylesheet
  def initialize
    @engine = Sass::Engine.new('@import "stylesheet"',
      style: :compressed,
      syntax: :scss,
      load_paths: [App::ROOT.join('app/assets/').realpath],
    )
  end

  def call(env)
    #TODO: caching
    [200, {}, [@engine.render]]
  end
end
