module HTTPCache
  MalformedDateString = Class.new(StandardError)
  MalformedETag = Class.new(StandardError)

  def self.if_modified_since(last_modified, env, &block)
    response(env: env, last_modified: last_modified, &block)
  end

  def self.if_none_match(etag, env, &block)
    response(env: env, etag: etag, &block)
  end

  def self.response(env:, last_modified: nil, etag: nil)
    headers = response_headers(last_modified: last_modified, etag: etag)

    if requires_response?(env: env, last_modified: last_modified, etag: etag)
      [ 200, headers, yield ]
    else
      [ 304, headers, [] ]
    end
  end

  private

  def self.requires_response?(env:, last_modified: nil, etag: nil)
    # from RFC 7232:
    #
    # A recipient must ignore If-Modified-Since if the request contains an
    # If-None-Match header field; the condition in If-None-Match is considered
    # to be a more accurate replacement for the condition in If-Modified-Since,
    # and the two are only combined for the sake of interoperating with older
    # intermediaries that might not implement If-None-Match.

    if env['HTTP_IF_NONE_MATCH']
      none_match?(etag, env)
    elsif env['HTTP_IF_MODIFIED_SINCE']
      modified_since?(last_modified, env)
    else
      true
    end
  end

  def self.modified_since?(last_modified, env)
    return true unless last_modified
    header = env['HTTP_IF_MODIFIED_SINCE']
    return true unless header
    Time.httpdate(header) < last_modified
  rescue ArgumentError
    raise MalformedDateString
  end

  def self.none_match?(etag, env)
    return true unless etag
    header = env['HTTP_IF_NONE_MATCH']
    return true unless header
    parse_etag(header) != etag
  end

  def self.response_headers(last_modified: nil, etag: nil)
    headers = {}
    headers['Last-Modified'] = last_modified.httpdate if last_modified
    headers['ETag'] = unparse_etag(etag) if etag
    headers
  end

  def self.unparse_etag(etag, weak: true)
    #TODO: should probably check that the etag string only contains valid characters.
    #      i.e. ascii characters 0-127. See: http://stackoverflow.com/questions/6719214/syntax-for-etag

    prefix = weak ? 'W/' : ''
    body = etag.gsub('"', '\"')

    prefix + '"' + body + '"'
  end

  def self.parse_etag(header)
    unless header.end_with?('"')
      raise MalformedETag, "ETag not quoted properly"
    end

    start = case
            when header.start_with?('W/"') then 3
            when header.start_with?('"') then 1
            else raise MalformedETag, "Etag not quoted properly"
            end

    if header.length - start - 1 <= 0
      raise MalformedETag, "ETag appears to be empty"
    end

    header[start..-2].gsub('\"', '"')
  end
end
