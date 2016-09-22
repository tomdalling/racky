require 'unit_test'
require 'pigeon/struct'

class PigeonStructTest < UnitTest
  Person = Pigeon::Struct.define do
    def_attr :name, default: 'Rigby'
    def_attr :age, coercer: method(:Integer)
  end

  def test_ctor_and_attrs
    tom = Person.new(name: 'Tom', age: 104)
    expect(tom.name) == 'Tom'
    expect(tom.age) == 104
  end

  def test_subscript
    tom = Person.new(age: 105)
    expect(tom[:age]) == 105
  end

  def test_with
    original = Person.new(name: 'Bart', age: 55)
    renamed = original.with(name: 'Lisa')

    expect(original.name) == 'Bart'
    expect(renamed.name) == 'Lisa'
    expect(renamed.age) == 55
  end

  def test_defaults
    rigby = Person.new(age: 10)
    expect(rigby.name) == 'Rigby'
  end

  def test_coercer
    hex = Person.new(age: '0xFF')
    expect(hex.age) == 255
  end

  def test_to_h
    person = Person.new(name: 'Fred', age: 66)
    expect(person.to_h) == { name: 'Fred', age: 66 }
  end

  def test_attr_constant
    expect(Person::ATTRIBUTE_DEFINITIONS.keys) == [:name, :age]
  end

  def test_missing_attr
    ex = assert_raises { Person.new({}) }
    expect(ex.message) == "Missing attribute :age for PigeonStructTest::Person"
  end

  def test_extraneous_attrs
    ex = assert_raises { Person.new(age: 1, wabbajack: 2, blah: 3) }
    expect(ex.message) == "Extraneous attributes for PigeonStructTest::Person: :wabbajack, :blah"
  end

  def test_immutable
    expect(Person::ATTRIBUTE_DEFINITIONS.frozen?) == true
    expect(Person.new(age: 3).frozen?) == true
  end

  def test_equality
    p1 = Person.new(name: 'Fred', age: 33)
    p2 = Person.new(name: 'Fred', age: 33)
    different = Person.new(name: 'Fred', age: 44)

    expect(p1) == p2
    expect(p1.hash) == p2.hash
    expect(p1.eql?(p2)) == true

    expect(p1) != different
    expect(p1.hash) != different.hash
    expect(p1.eql?(different)) == false
  end

  def test_inspect
    person = Person.new(name: 'Dowl', age: 4321)
    expect(person.inspect).includes('PigeonStructTest::Person', '"Dowl"', '4321')
  end

  CatPerson = Pigeon::Struct.define_from(Person) do
    def_attr :cats
  end

  def test_define_from
    person = CatPerson.new(age: 123, cats: 100)
    expect(person).has_attrs(name: 'Rigby', age: 123, cats: 100)
  end
end

