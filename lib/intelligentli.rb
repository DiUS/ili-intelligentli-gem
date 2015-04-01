require 'httparty'
require 'httmultiparty'

class Intelligentli
  def initialize base_uri, key, secret_key
    @base_uri   = base_uri
    @key        = key
    @secret_key = secret_key
  end

  def streams
    do_request 'get', '/api/v2/streams'
  end

  def upload_stream(body) # json
    do_request 'post', '/api/v2/streams', body
  end

  def upload_octet_stream(body) # metadata json
    do_multi_request 'post', '/api/v2/octet_streams', body
  end

  private

  def build_headers verb, uri, body = nil, content_type = 'application/json'
    md5sum  = body ? Digest::MD5.hexdigest(body) : ''
    date    = Time.now.httpdate
    token   = Gibberish::HMAC(@secret_key, "#{verb.upcase}#{uri}#{md5sum}#{date}", digest: :sha256)

    headers = {
      'User-key'     => @key,
      'User-token'   => token,
      'Date'         => date
    }
    headers['Content-Type'] = content_type if content_type
    headers
  end

  def do_request verb, uri, body = nil
    headers = build_headers verb, uri, body

    HTTParty.send verb, "#{@base_uri}#{uri}", headers: headers, body: body
  end

  def do_multi_request verb, uri, body
    headers = build_headers verb, uri, nil, nil

    query = { metadata: body }
    body = JSON.parse(body, symbolize_names: true)
    filenames = body[:octet_streams].each do |ostream|
      ostream[:data].each do |point|
        filename = point[:filename]
        query[filename.to_sym] = File.new filename
      end
    end

    HTTMultiParty.send verb, "#{@base_uri}#{uri}", headers: headers, query: query
  end
end
