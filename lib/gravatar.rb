require 'cgi'

module Gravatar
  DEFAULT_OPTIONS = {
    size: 200,
    default: 'mm',
  }

  def self.url(email, options={})
    options = DEFAULT_OPTIONS.merge(options)
    params = {
      s: Integer(options.fetch(:size)),
      d: CGI.escape(options.fetch(:default)),
    }
    query_string = params.any? ?
       '?' + params.map{ |k, v| "#{k}=#{v}" }.join('&') :
       ''

    hash = Digest::MD5.hexdigest(email.downcase)

    "https://secure.gravatar.com/avatar/#{hash}#{query_string}"
  end
end
