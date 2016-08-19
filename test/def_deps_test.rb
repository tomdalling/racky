require 'unit_test'
require 'def_deps'

class DefDepsTest < UnitTest
  class Farm
    include DefDeps[:cat, 'dog', rabbit: 'animal.rabbit']
  end

  class OldMcDonaldsFarm < Farm
    include DefDeps[:eieio, rabbit: 'bugsbunny']
  end

  def test_declared_dependencies
    expect(Farm::DECLARED_DEPENDENCIES) == {
      cat: 'cat',
      dog: 'dog',
      rabbit: 'animal.rabbit',
    }
  end

  def test_attributes
    farm = Farm.new(cat: 'meow', dog: 'woof', rabbit: 'twitch')
    expect(farm.cat) == 'meow'
    expect(farm.dog) == 'woof'
    expect(farm.rabbit) == 'twitch'
  end

  def test_missing_deps
    assert_raises(DefDeps::MissingDependency) do
      Farm.new(cat: 'meow', dog: 'woof')
    end
  end

  def test_inheritance__declared_deps
    expect(DefDeps.get(OldMcDonaldsFarm)) == {
      eieio: 'eieio',
      rabbit: 'bugsbunny',
      cat: 'cat',
      dog: 'dog',
    }
  end

  def test_inheritance__attributes
    farm = OldMcDonaldsFarm.new(
      eieio: 'and on that farm',
      rabbit: 'thats all folks',
      cat: 'meow',
      dog: 'woof',
    )

    expect(farm.rabbit) == 'thats all folks'
    expect(farm.dog) == 'woof'
  end

  def test_inheritance__missing_deps
    assert_raises(DefDeps::MissingDependency) do
      OldMcDonaldsFarm.new(eieio: '', rabbit: '')
    end
  end
end

