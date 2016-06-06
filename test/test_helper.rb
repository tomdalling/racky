class Test < Minitest::Test
  def expect(actual, op, expected=nil)
    case op
    when :== then assert_equal(expected, actual)
    when :is_a then assert_kind_of(expected, actual)
    when :is_nil then assert_nil(actual)
    when :includes then assert_includes(actual, expected)
    when :starts_with then assert_send([actual, :start_with?, expected])
    else fail("Unhandled expectation: #{op}")
    end
  end

  class ExpectWrapper
    def initialize(actual, test)
      @actual = actual
      @test = test
    end

    def to_equal(expected)
      @test.assert_equal(expected, @actual)
    end
  end
end
