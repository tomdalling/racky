require 'unit_test'
require 'def_deps'

class DefDepsTest < UnitTest
  class X
    include DefDeps[:cat, 'dog', rabbit: 'animal.rabbit']
  end

  def test_declared_dependencies
    expect(X::DECLARED_DEPENDENCIES) == {
      cat: 'cat',
      dog: 'dog',
      rabbit: 'animal.rabbit',
    }
  end

  def test_attributes
    x = X.new(cat: 'meow', dog: 'woof', rabbit: 'twitch')
    expect(x.cat) == 'meow'
    expect(x.dog) == 'woof'
    expect(x.rabbit) == 'twitch'
  end

  def test_missing_deps
    assert_raises(DefDeps::MissingDependency) do
      X.new(cat: 'meow', dog: 'woof')
    end
  end
end

