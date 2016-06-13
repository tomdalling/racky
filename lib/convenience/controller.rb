require 'controllers'
require 'params'
require 'session'

module Convenience
  class Controller
    attr_reader :env

    def self.call(env)
      new(env).call
    end

    def initialize(env)
      @env = env
    end

    def params
      return @params if defined? @params

      @params = begin
        schema = self.class.const_defined?(:PARAMS) && self.class::PARAMS
        schema ? schema.get!(env) : Params.get(env)
      end
    end

    def session
      Session.get(env)
    end

    def self.define_params(params)
      const_set(:PARAMS, Params.define(params))
    end

    def redirect(path)
      Controllers::Redirect.new(path).call(env)
    end

    def view(name, vars={})
      Controllers::View.new(name).call(env, vars)
    end
  end
end
