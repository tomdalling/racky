module Expectations
  def expect(value)
    location = caller(1,1).first
    Wrapper.new(value, self, location)
  end

  class Wrapper
    def initialize(value, test, source_location)
      @value = value
      @test = test
      @source_location = source_location
    end

    def ==(expected)
      @test.assert_equal(expected, @value, _msg)
    end

    def is_a(klass)
      @test.assert_kind_of(klass, @value, _msg)
    end

    def is_nil
      @test.assert_nil(@value, _msg)
    end

    def is_not_nil
      @test.refute_nil(@value, _msg)
    end

    def includes(*elements)
      elements.each do |e|
        @test.assert_includes(@value, e, _msg)
      end
    end

    def starts_with(prefix)
      @test.assert_send([@value, :start_with?, prefix], _msg)
    end

    def _msg
      "Called from: #{@source_location}"
    end
  end
end
