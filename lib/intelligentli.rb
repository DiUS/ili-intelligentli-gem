require 'httparty'
require 'httmultiparty'
require 'faye/websocket'
require_relative 'authentication'

class Intelligentli

  def initialize server, key, secret
    @server, @key, @secret = server, key, secret
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

  def watch uri
    headers = Authentication.build_headers @key, @secret, 'get', uri
    ws = Faye::WebSocket::Client.new("#{@server}#{uri}", nil, headers: headers)
    ws.on(:open) { |event| ws.send('{"message_sequence": 0}') }
    ws.on(:message) do |event|
      payload = JSON.parse(event.data, symbolize_names: true)
      message = JSON.parse(payload[:message], symbolize_names: true)
      yield message
    end
    ws.on(:close) { |event| ws = nil }
  end

  private

  def do_request verb, uri, body = nil
    headers = Authentication.build_headers @key, @secret, verb, uri, body
    response = HTTParty.send verb, "#{@server}#{uri}", headers: headers, body: body
    JSON.parse(response.body, symbolize_names: true)
  end

  def do_multi_request verb, uri, body
    headers = Authentication.build_headers @key, @secret, verb, uri, nil, nil

    query = { metadata: body }
    body = JSON.parse(body, symbolize_names: true)
    filenames = body[:octet_streams].each do |ostream|
      ostream[:data].each do |point|
        filename = point[:filename]
        query[filename.to_sym] = File.new filename
      end
    end

    response = HTTMultiParty.send verb, "#{@server}#{uri}", headers: headers, query: query
    JSON.parse(response.body, symbolize_names: true)
  end
end
