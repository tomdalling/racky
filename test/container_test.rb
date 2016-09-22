require 'unit_test'
require 'container'

class ContainerTest < UnitTest
  def test_registration
    container = Container.new
    container.register('cat') { 'meow' }
    expect(container['cat']) == 'meow'
    expect(container.resolve('cat')) == 'meow'
  end

  def test_missing_key
    ex = assert_raises(Container::KeyNotFound) do
      Container.new.resolve('hello')
    end
    expect(ex.message) == 'Key not found in container: "hello"'
  end

  def test_duplicate_key
    container = Container.new
    container.register('cat') { 'meow' }
    ex = assert_raises(Container::DuplicateKey) do
      container.register('cat') { 'woof' }
    end
    expect(ex.message) == 'Container already has a value registered for key: "cat"'
  end

  def test_cyclic_dependencies
    container = Container.new
    container.register('mouse') { |c| c['cheese'] }
    container.register('cheese') { |c| c['milk'] }
    container.register('milk') { |c| c['pregnant.cat'] }
    container.register('pregnant.cat') { |c| c['mouse'] }

    ex = assert_raises(Container::CyclicDependencies) do
      container['cheese']
    end
    expect(ex.message) == 'Cyclic dependencies not allowed (cycle: "cheese" -> "milk" -> "pregnant.cat" -> "mouse" -> "cheese")'
  end

  def test_missing_block
    ex = assert_raises(ArgumentError) do
      Container.new.register('x')
    end
    expect(ex.message) == 'Must provide a block to #register'
  end

  def test_bad_option
    ex = assert_raises(ArgumentError) do
      Container.new.register('x', bad_option: 'moo', bad2: true) { 'x' }
    end
    expect(ex.message) == 'Unrecognised option(s): :bad_option, :bad2'
  end

  def test_memoization_option
    container = Container.new

    meow = 0
    container.register('cat') { meow += 1 }
    expect(container['cat']) == 1
    expect(container['cat']) == 1
    expect(container['cat']) == 1

    woof = 10
    container.register('dog', memoize: false) { woof += 1 }
    expect(container['dog']) == 11
    expect(container['dog']) == 12
    expect(container['dog']) == 13
  end
end
