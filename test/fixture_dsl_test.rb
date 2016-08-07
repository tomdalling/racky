require 'unit_test'
require 'fixture_dsl'

class FixtureDSLTest < UnitTest
  def test_it
    dsl = FixtureDSL.new
    dsl.instance_eval do
      def_tables user: :accounts, fox: :foxes

      user id: 1, name: 'John'
      post title: 'Posty', author_id: 1
      post title: 'Other post'
      fox color: 'red'
    end

    expect(dsl.records_by_table) == {
      accounts: [
        { id: 1, name: 'John' },
      ],
      posts: [
        { title: 'Posty', author_id: 1 },
        { title: 'Other post' },
      ],
      foxes: [
        { color: 'red' },
      ],
    }
  end
end
