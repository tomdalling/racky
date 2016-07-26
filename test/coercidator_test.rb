require 'unit_test'
require 'coercidator'

class CoercidatorTest < UnitTest
  def test_failure
    f = Coercidator::Failure.new(:coerc, 5, :not_6, "It wasn't six")
    f2 = f.with_extended_path('hello')
    f3 = f2.with_extended_path(3)

    {
      schema: :coerc,
      value: 5,
      type: :not_6,
      message: "It wasn't six",
    }.each do |attr, expected|
      expect(f.send(attr)) == expected
      expect(f2.send(attr)) == expected
      expect(f3.send(attr)) == expected
    end

    expect(f.path) == []
    expect(f2.path) == ['hello']
    expect(f3.path) == [3, 'hello']
  end

  def test_result
    r = Coercidator::Result.new({})
    expect(r.value) == {}
    expect(r.failures) == []

    r2 = Coercidator::Result.new({a: 1})
    r.merge!(r2) { |left, right| left.merge(right) }
    expect(r.value) == {a: 1}
    expect(r.failures) == []

    r3 = Coercidator::Result.new({b: 2})
    r.merge!(r3){ |left, right| left.merge(right) }
    expect(r.value) == {a: 1, b: 2}
    expect(r.failures) == []

    failure = Coercidator::Failure.new(:booly, 'yep', :not_a_bool, "yep is not a bool")
    r4 = Coercidator::Result.new(nil, [failure])
    r.merge!(r4){ |left, right| left.merge(right) }
    expect(r.value) == {a: 1, b: 2}
    expect(r.failures) == [failure]

    # make sure merged results are not mutated
    expect(r2.value) == {a: 1}
    expect(r2.failures) == []
    expect(r3.value) == {b: 2}
    expect(r3.failures) == []
  end

  def test_coercidation
    schema = Coercidator::HashSchema.new(
      name: Coercidator::StringSchema,
      updated_at: Coercidator::TimeSchema,
      remember_me: Coercidator::BoolSchema,
    )
    input = {
      name: 'Tom',
      updated_at: '2016-03-28T13:14:15+10:00',
    }

    result = schema.coercidate(input)

    expect(result.failures) == []
    expect(result.value) == {
      name: 'Tom',
      updated_at: Time.new(2016, 03, 28, 13, 14, 15, '+10:00'),
      remember_me: false,
    }
  end

  def test_compiler
    compiler = Coercidator::Compiler.new(
      String => Coercidator::StringSchema,
      Time => Coercidator::TimeSchema,
      :bool => Coercidator::BoolSchema,
    )

    schema = compiler.compile(
      name: String,
      updated_at: Time,
      remember_me: :bool,
    )

    expect(schema).is_a Coercidator::HashSchema
    expect(schema.attr_schemas[:name]) == Coercidator::StringSchema
    expect(schema.attr_schemas[:updated_at]) == Coercidator::TimeSchema
    expect(schema.attr_schemas[:remember_me]) == Coercidator::BoolSchema
  end

  def test_failure_explainer
    failures = [
      Coercidator::Failure.new(:bool, 5, :not_a_bool, "Ain't no bool", [:user, :remember_me]),
      Coercidator::Failure.new(:str, 6, :not_a_string, "Ain't no string", []),
    ]

    explanation = Coercidator::FailureExplainer.call(failures)

    expect(explanation) == <<~EOS.strip
      Failure: Ain't no bool
        Value: 5
        Path: [:user, :remember_me]
        Schema: bool
        Failure Type: :not_a_bool

      Failure: Ain't no string
        Value: 6
        Path: []
        Schema: str
        Failure Type: :not_a_string
    EOS
  end
end
