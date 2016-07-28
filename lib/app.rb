require 'template'
require 'dry/component/container'
require 'pigeon/routing'

class App < Dry::Component::Container
  ROOT = Pathname.new(__FILE__).dirname.dirname

  load_paths! 'app'
  configure do |config|
    config.root = ROOT
    config.auto_register = ['app/controllers', 'app/repos', 'app/queries']
  end

  namespace 'templates' do
    Dir.glob("#{ROOT}/app/templates/**/*.erb") do |path|
      register(File.basename(path, '.*')) do
        Template.new(File.read(path), path)
      end
    end
  end

  register 'router' do
    resolver = ->(controller_key){ resolve("controllers.#{controller_key}") }
    Pigeon::Routing::DSL.new(resolver).eval_file(ROOT + 'app/routes.rb')
  end

  def self.call(env)
    resolve('router').call(env)
  end

  finalize!
end
