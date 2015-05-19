require 'httparty'
require 'httmultiparty'
require 'faye/websocket'
require_relative 'authentication'

class Intelligentli

  def initialize server, key, secret
    @server, @key, @secret = server, key, secret
  end

  %i(get put post delete).each do |verb|
    define_method verb do |uri, body = nil|
      headers  = Authentication.build_headers @key, @secret, verb, uri, body
      response = HTTParty.send verb, "#{@server}#{uri}", headers: headers, body: body
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  %i(multi_post).each do |verb|
    define_method verb do |uri, body|
      headers = Authentication.build_headers @key, @secret, verb, uri, nil, nil
      query   = { metadata: body }
      body    = JSON.parse(body, symbolize_names: true)
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

  # deprecated commands
  def streams
    self.get '/api/v2/streams'
  end

  def upload_stream(body)
    self.post '/api/v2/streams', body.to_json
  end

  def upload_octet_stream(body)
    self.multi_post '/api/v2/octet_streams', body.to_json
  end

end
