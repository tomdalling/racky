require 'feature_test'

class QueriesHomepageTest < FeatureTest
  def test_it
    query = resolve('queries/homepage')

    result = query.call

    expect(result).is_not_nil
    expect(result.latest.title) == 'Latest Baitest'
    expect(result.featured.title) == 'Featured Peatured'
  end
end
