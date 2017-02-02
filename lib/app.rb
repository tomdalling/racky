require 'pathname'
require 'template'
require 'pigeon/routing'
require 'pigeon/container'
require 'session'
require 'sequel'
require 'page'
require 'inflecto'
require 'def_deps'
require 'request_handler'

#TODO: These empty modules exists so that classes can do this:
#
#     class Endpoints::Whatever
#
# instead of this:
#
#     module Endpoints
#       class Whatever
#
# These should probably be elsewhere.
module Endpoints; end
module Views; end
module Queries; end
module Commands; end
module ViewModels; end

class App
  ROOT = Pathname.new(__FILE__).dirname.dirname

  attr_reader :container

  def initialize(config)
    @container = Pigeon::Container.new
    @container.register('config') { config }
    @container.register('db') { db_connection }
    @container.register('page') { page }
    register_templates!
    register_app_directory!('queries')
    register_app_directory!('commands')
    register_app_directory!('endpoints')
    @container.register('router') { router }
  end

  def config
    @container.resolve('config')
  end

  def db_connection
    Sequel.connect(config.db_connection_str).tap do |db|
      #TODO: This needs to be moved out.
      #      Creating tables should happen manually, not automatically.
      if db.tables.empty?
        schema_path = ROOT + 'app/schema.rb'
        db.instance_eval(schema_path.read, schema_path.to_s, 1)
      end
    end
  end

  def page
    resolver = ->(key){ @container["templates/#{key}"] }
    Page.new(resolver)
  end

  def register_templates!
    Dir.glob("#{ROOT}/app/templates/**/*.erb") do |path|
      name = File.basename(path, '.*')
      container.register("templates/#{name}") do
        Template.new(File.read(path), path)
      end
    end
  end

  def register_app_directory!(dirname)
    DefDepsClassFile.glob("app", "#{dirname}/**/*.rb") do |class_file|
      container.register(class_file.container_key, &class_file)
    end
  end

  def router
    resolver = Proc.new do |key|
      @container.resolve(key.is_a?(Symbol) ? "endpoints/#{key}" : key)
    end
    Pigeon::Routing::DSL.new(resolver).eval_file(ROOT + 'app/routes.rb')
  end

  def call(env)
    @container.resolve('router').call(env)
  end
end

#TODO: this needs to be moved somewhere
class DefDepsClassFile
  attr_reader :container_key

  def self.glob(dir, path_pattern)
    dir = Pathname(dir)

    Pathname.glob(dir.join(path_pattern)) do |path|
      this = new(path.relative_path_from(dir))
      yield this
    end
  end

  def initialize(path)
    @container_key = Pathname(path).sub_ext('').to_s
  end

  def to_proc
    method(:instantiate).to_proc
  end

  def instantiate(container)
    require @container_key
    klass_name = Inflecto.camelize(@container_key)
    klass = Inflecto.constantize(klass_name)
    args = ctor_args(klass, container)
    klass.new(*args)
  end

  def ctor_args(klass, container)
    if klass.const_defined?(:DECLARED_DEPENDENCIES)
      [deps_for(klass, container)]
    else
      []
    end
  end

  def deps_for(klass, container)
    DefDeps.get(klass).map do |attr, key|
      [attr, container[key]]
    end.to_h
  end
end
