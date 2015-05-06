require 'faye/websocket'
require 'json'
require 'chronic_duration'
require_relative 'authentication'

class StreamWatcher

  include Authentication

  def self.login server, key, secret_key
    @@server     = server.gsub(/^http/, 'ws')
    @@key        = key
    @@secret_key = secret_key
  end

  def initialize uri, options, block
    @uri    = uri
    @block  = block
    @data   = []
    @span   = ChronicDuration.parse(options[:span]) if options[:span]
    @limit  = options[:limit]
    puts "WARNING: Unbounded memory usage for #{uri}" unless @span || @limit
  end

  def run
    headers = build_headers 'get', @uri
    ws = Faye::WebSocket::Client.new("#{@@server}#{@uri}", nil, headers: headers)
    ws.on(:open)    { |event| ws.send('{"message_sequence": 0}') }
    ws.on(:message) { |event| extract_data(event); @block.call(@data) }
    ws.on(:close)   { |event| ws = nil }
  end

  def key
    @@key
  end

  def secret
    @@secret_key
  end

  private

  def extract_data(event)
    @data.concat data_points event
    @data = @data.sort_by { |point| point[:time] }
    @data = @data.reject  { |point| point[:time] < Time.now - @span } if @span
    @data = @data[-@limit..-1] if @limit && @data.length > @limit
  end

  def data_points(event)
    payload = JSON.parse(event.data, symbolize_names: true)
    message = JSON.parse(payload[:message], symbolize_names: true)
    divisor = case message[:time_precision]
              when 'us'
                1000000
              when 'ms'
                1000
              else
                1
              end
    message[:data].map do |point|
      {
        time: Time.at(point[:time]/divisor),
        value: point[:value]
      }
    end
  end

end
