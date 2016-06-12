module Routing
  def self.define(&block)
    dsl = DSL.new
    dsl.instance_eval(&block)
    dsl.make_root_router
  end
end

require 'routing/pattern'
require 'routing/always'
require 'routing/endpoint'
require 'routing/namespace'
require 'routing/router'
require 'routing/dsl'
