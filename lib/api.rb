require 'httparty'
require 'httmultiparty'
require 'faye/websocket'
require_relative 'authentication'

module Intelligentli

  class Api

    def initialize server, key, secret
      @server, @key, @secret = server, key, secret
    end

    %i(get put post delete).each do |verb|
      define_method verb do |uri, body = nil|
        headers  = Authentication.build_headers @key, @secret, verb, uri, body
        response = HTTParty.send verb, "#{@server}#{uri}", headers: headers, body: body, verify: false
        JSON.parse(response.body, symbolize_names: true)
      end
    end

    def multi_post uri, body
      headers = Authentication.build_headers @key, @secret, 'post', uri, nil, nil
      query   = { metadata: body }
      body    = JSON.parse(body, symbolize_names: true)
      filenames = body[:octet_streams].each do |ostream|
        ostream[:data].each do |point|
          filename = point[:filename]
          query[filename.to_sym] = File.new filename
        end
      end

      response = HTTMultiParty.post "#{@server}#{uri}", headers: headers, query: query, verify: false
      JSON.parse(response.body, symbolize_names: true)
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
      ws.on(:close) { |event| raise 'Connection closed!' }
    end

  end

end
