require 'coercidator'

module Params
  def self.get(env)
    case
    when env['QUERY_STRING'].length > 0
      Rack::Utils.parse_nested_query(env['QUERY_STRING'])
    when env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
      body = env['rack.input']
      body.rewind
      Rack::Utils.parse_nested_query(body.read)
    else
      {}
    end
  end

  SCHEMA_COMPILER = Coercidator::Compiler.new(
    String => Coercidator::StringSchema,
    Time => Coercidator::TimeSchema,
    :bool => Coercidator::BoolSchema,
  )

  class RequirementError < StandardError; end

  def self.require!(env, uncompiled_schema)
    schema = SCHEMA_COMPILER.compile(uncompiled_schema)
    params = get(env)
    result = schema.coercidate(params)
    if result.failures.empty?
      result.value
    else
      raise RequirementError, Coercidator::FailureExplainer.call(result.failures)
    end
  end
end
