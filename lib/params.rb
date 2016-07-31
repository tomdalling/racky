require 'coercidator'
require 'pigeon/routing'

module Params
  def self.get(env)
    from_request(env).merge(from_routing(env))
  end

  def self.from_request(env)
    content_type = env.fetch('CONTENT_TYPE', '')

    case
    when env['QUERY_STRING'].length > 0
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    when content_type == 'application/x-www-form-urlencoded'
      body = env['rack.input']
      body.rewind
      Rack::Utils.parse_nested_query(body.read)
    when content_type.start_with?('multipart/form-data')
      Rack::Multipart.parse_multipart(env)
    else
      {}
    end
  end

  def self.from_routing(env)
    env.fetch(Pigeon::Routing::CAPTURES_ENV_KEY, {})
  end

  SCHEMA_COMPILER = Coercidator::Compiler.new(
    String => Coercidator::StringSchema,
    Time => Coercidator::TimeSchema,
    :bool => Coercidator::BoolSchema,
  )

  def self.define(uncompiled_schema)
    schema = SCHEMA_COMPILER.compile(uncompiled_schema)
    Definition.new(schema)
  end

  class InvalidParamsError < StandardError; end

  class Definition
    def initialize(schema)
      @schema = schema
    end

    def get!(env)
      params = Params.get(env)
      result = @schema.coercidate(params)
      if result.failures.empty?
        result.value
      else
        raise InvalidParamsError, Coercidator::FailureExplainer.call(result.failures)
      end
    end
  end
end
