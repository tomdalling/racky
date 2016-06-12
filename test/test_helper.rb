require 'minitest/autorun'
require 'minitest/pride'

ROOT_DIR = File.expand_path('../..', __FILE__)
$LOAD_PATH.unshift(File.expand_path('test', ROOT_DIR))
$LOAD_PATH.unshift(File.expand_path('lib', ROOT_DIR))

class Test < Minitest::Test
  def expect(value)
    e = ExpectationWrapper.new(value, self)
    location = caller(1,1).first
    NicerErrorsWrapper.new(e, location)
  end
end

class NicerErrorsWrapper < BasicObject
  def initialize(expectation, location)
    @expectation = expectation
    @location = location
  end

  def ==(other)
    self.__forward(:==, other)
  end

  def !=(other)
    self.__forward(:!=, other)
  end

  def method_missing(sym, *args, &block)
    self.__forward(sym, *args, &block)
  end

  def __forward(sym, *args, &block)
    @expectation.send(sym, *args, &block)
  rescue ::Minitest::Assertion => e
    ::Kernel.puts "Assertion failure at: #{@location}"
    ::Kernel.raise(e)
  end
end

class ExpectationWrapper
  def initialize(value, test)
    @value = value
    @test = test
  end

  def ==(expected)
    @test.assert_equal(expected, @value)
  end

  def is_a(klass)
    @test.assert_kind_of(klass, @value)
  end

  def is_nil
    @test.assert_nil(@value)
  end

  def is_not_nil
    @test.refute_nil(@value)
  end

  def includes(*elements)
    elements.each do |e|
      @test.assert_includes(@value, e)
    end
  end

  def starts_with(prefix)
    @test.assert_send([@value, :start_with?, prefix])
  end
end
