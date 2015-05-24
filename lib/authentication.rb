require 'gibberish'

module Intelligentli

  module Authentication

    def self.build_headers key, secret, verb, uri, body = nil, content_type = 'application/json'
      md5sum  = body ? Digest::MD5.hexdigest(body) : ''
      date    = Time.now.httpdate
      token   = Gibberish::HMAC256(secret, "#{verb.upcase}#{uri}#{md5sum}#{date}")

      headers = {
        'User-key'     => key,
        'User-token'   => token,
        'Date'         => date
      }
      headers['Content-Type'] = content_type if content_type
      headers
    end

  end

end
