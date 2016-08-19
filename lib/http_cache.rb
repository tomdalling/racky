module HTTPCache
  MalformedDateString = Class.new(StandardError)
  MalformedETag = Class.new(StandardError)

  def self.if_modified_since(last_modified, env, &block)
    response(env, last_modified: last_modified, &block)
  end

  def self.if_none_match(etag, env, &block)
    response(env, etag: etag, &block)
  end

  def self.response(env, options_hash)
    options = Options.new(options_hash)
    headers = response_headers(options)

    if requires_response?(env, options)
      [ 200, headers, yield ]
    else
      [ 304, headers, [] ]
    end
  end

  private

  def self.requires_response?(env, options)
    # from RFC 7232:
    #
    # A recipient must ignore If-Modified-Since if the request contains an
    # If-None-Match header field; the condition in If-None-Match is considered
    # to be a more accurate replacement for the condition in If-Modified-Since,
    # and the two are only combined for the sake of interoperating with older
    # intermediaries that might not implement If-None-Match.

    if env['HTTP_IF_NONE_MATCH']
      none_match?(options.etag, env)
    elsif env['HTTP_IF_MODIFIED_SINCE']
      modified_since?(options.last_modified, env)
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

  def self.response_headers(options)
    headers = {}
    headers.merge!(cache_control_header(options))
    headers['Last-Modified'] = options.last_modified.httpdate if options.last_modified
    headers['ETag'] = unparse_etag(options.etag) if options.etag
    headers
  end

  def self.cache_control_header(options)
    type = options.cache_control || :private
    unless CACHE_CONTROL_TYPES.include?(type)
      valid = CACHE_CONTROL_TYPES.map(&:inspect).join(', ')
      raise ArgumentError, "Cache-Control type must be one of #{valid} (was #{type.inspect})"
    end

    parts = begin
      if type == :no_cache
        ['no-cache', 'no-store']
      else
        [type.to_s] + (options.max_age ? ["max-age=#{Integer(options.max_age)}"] : [])
      end
    end

    { 'Cache-Control' => parts.join(', ') }
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

  CACHE_CONTROL_TYPES = [:private, :public, :no_cache]
  OPTION_KEYS = [:etag, :last_modified, :cache_control, :max_age]
  Options = Struct.new(*OPTION_KEYS) do
    def initialize(hash)
      super(*hash.values_at(*OPTION_KEYS))
    end
  end

end
