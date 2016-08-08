require 'unit_test'
require 'http_cache'

class HTTPCacheTest < UnitTest
  def test_if_modified_miss
    env = { 'HTTP_IF_MODIFIED_SINCE' => 'Tue, 07 Jul 2015 07:07:07 GMT' }
    last_modified = Time.utc(2015, 8, 8)

    response = HTTPCache.if_modified_since(last_modified, env) do
      ['Response body']
    end

    expect(response) == [
      200,
      { 'Last-Modified' => 'Sat, 08 Aug 2015 00:00:00 GMT' },
      ['Response body'],
    ]
  end

  def test_if_modified_hit
    env = { 'HTTP_IF_MODIFIED_SINCE' => 'Tue, 07 Jul 2015 07:07:07 GMT' }
    last_modified = Time.utc(2015, 6, 6)

    response = HTTPCache.if_modified_since(last_modified, env) do
      ['Response body']
    end

    expect(response) == [
      304,
      { 'Last-Modified' => 'Sat, 06 Jun 2015 00:00:00 GMT' },
      [],
    ]
  end

  def test_etag_parsing
    {
      'hi' => 'W/"hi"',
      'quo"tes' => 'W/"quo\"tes"',
    }.each do |input, expected_output|
      output = HTTPCache.unparse_etag(input)
      expect(output) == expected_output
      expect(HTTPCache.parse_etag(output)) == input
    end
  end

  def test_etag_miss
    env = { 'HTTP_IF_NONE_MATCH' => 'W/"abc123"' }
    etag = 'def456'

    response = HTTPCache.if_none_match(etag, env) { ['body'] }

    expect(response) == [
      200,
      { 'ETag' => 'W/"def456"' },
      ['body'],
    ]
  end

  def test_etag_hit
    env = { 'HTTP_IF_NONE_MATCH' => 'W/"abc123"' }
    etag = 'abc123'

    response = HTTPCache.if_none_match(etag, env) { ['body'] }

    expect(response) == [
      304,
      { 'ETag' => 'W/"abc123"' },
      []
    ]
  end

  def test_no_criteria_miss
    last_modified = Time.utc(2015, 11, 11)
    etag = 'abc123'

    response = HTTPCache.response(env: {}, last_modified: last_modified, etag: etag) do
      ['body']
    end

    expect(response) == [
      200,
      {
        'Last-Modified' => 'Wed, 11 Nov 2015 00:00:00 GMT',
        'ETag' => 'W/"abc123"',
      },
      ['body'],
    ]
  end

  def test_both_criteria_miss
    last_modified = Time.utc(2015, 11, 11)
    etag = 'abc123'
    env = {
      'HTTP_IF_NONE_MATCH' => 'W/"def456"',
      'HTTP_IF_MODIFIED_SINCE' => 'Sat, 06 Jun 2015 00:00:00 GMT',
    }

    response = HTTPCache.response(env: env, last_modified: last_modified, etag: etag) do
      ['body']
    end

    expect(response) == [
      200,
      {
        'Last-Modified' => 'Wed, 11 Nov 2015 00:00:00 GMT',
        'ETag' => 'W/"abc123"',
      },
      ['body'],
    ]
  end

  def test_both_criteria_hit
    last_modified = Time.utc(2015, 11, 11)
    etag = 'abc123'
    env = {
      'HTTP_IF_NONE_MATCH' => 'W/"abc123"',
      'HTTP_IF_MODIFIED_SINCE' => 'Wed, 11 Nov 2015 00:00:00 GMT',
    }

    response = HTTPCache.response(env: env, last_modified: last_modified, etag: etag) do
      ['body']
    end

    expect(response) == [
      304,
      {
        'Last-Modified' => 'Wed, 11 Nov 2015 00:00:00 GMT',
        'ETag' => 'W/"abc123"',
      },
      [],
    ]
  end

  def test_etag_miss_modified_hit
    last_modified = Time.utc(2015, 11, 11)
    etag = 'def456'
    env = {
      'HTTP_IF_NONE_MATCH' => 'W/"abc123"',
      'HTTP_IF_MODIFIED_SINCE' => 'Wed, 11 Nov 2015 00:00:00 GMT',
    }

    response = HTTPCache.response(env: env, last_modified: last_modified, etag: etag) do
      ['body']
    end

    expect(response) == [
      200,
      {
        'Last-Modified' => 'Wed, 11 Nov 2015 00:00:00 GMT',
        'ETag' => 'W/"def456"',
      },
      ['body'],
    ]
  end
end
