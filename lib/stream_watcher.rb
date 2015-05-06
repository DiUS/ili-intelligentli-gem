require 'faye/websocket'
require 'json'
require 'chronic_duration'
require_relative 'intelligentli'

class StreamWatcher

  include Authentication

  COMMON_SYMBOLS = %i(server key secret)
  COMMON_SYMBOLS.each { |symbol| define_method(symbol) { self.class.send(symbol) } }

  class << self
    attr_reader *COMMON_SYMBOLS

    def login server, key, secret
      @server, @key, @secret = server.gsub(/^http/, 'ws'), key, secret
    end
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
    ili = Intelligentli.new(server, key, secret)
    ili.watch @uri do |message|
      extract_data(message)
      @block.call(@data)
    end
  end

  private

  def extract_data(message)
    @data.concat data_points(message)
    @data = @data.sort_by { |point| point[:time] }
    @data = @data.reject  { |point| point[:time] < Time.now - @span } if @span
    @data = @data[-@limit..-1] if @limit && @data.length > @limit
  end

  def data_points(message)
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
