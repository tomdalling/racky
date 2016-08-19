require 'sass'

# This should probably be part of the build process, not an endpoint.
class Endpoints::Stylesheet
  def initialize
    @engine = Sass::Engine.new('@import "stylesheet"',
      style: :compressed,
      syntax: :scss,
      load_paths: [App::ROOT.join('app/assets/').realpath],
    )
  end

  def call(env)
    [200, {}, [@engine.render]]
  end
end
