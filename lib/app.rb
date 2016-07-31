require 'template'
require 'dry/component/container'
require 'pigeon/routing'
require 'session'
require 'sequel'

#TODO: These empty modules exists so that classes can do this:
#
#     class Controllers::Whatever
#
# instead of this:
#
#     module Controllers
#       class Whatever
#
# These should probably be elsewhere.
module Controllers
end
module Views
end
module Queries
end
module Commands
end

class App < Dry::Component::Container
  ROOT = Pathname.new(__FILE__).dirname.dirname

  load_paths! 'app'
  configure do |config|
    config.root = ROOT
    config.auto_register = [
      'app/controllers',
      'app/queries',
      'app/commands',
    ]
  end

  begin # DB
    db = Sequel.sqlite(':memory:')
    schema_path = ROOT + 'app/schema.rb'
    db.instance_eval(schema_path.read, schema_path.to_s, 1)
    register('db', db)
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
