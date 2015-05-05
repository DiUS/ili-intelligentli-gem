require 'httparty'
require 'httmultiparty'
require_relative 'authentication'

class Intelligentli

  include Authentication

  def initialize server, key, secret_key
    @server     = server
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

  def do_request verb, uri, body = nil
    headers = build_headers verb, uri, body

    HTTParty.send verb, "#{@server}#{uri}", headers: headers, body: body
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

    HTTMultiParty.send verb, "#{@server}#{uri}", headers: headers, query: query
  end
end
