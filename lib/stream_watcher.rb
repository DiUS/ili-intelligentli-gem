require 'faye/websocket'
require 'json'
require 'chronic_duration'

class StreamWatcher

  def initialize ili, uri, options, block
    @ili, @uri, @block = ili, uri, block
    @data   = []
    @span   = ChronicDuration.parse(options[:span]) if options[:span]
    @limit  = options[:limit]
    puts "WARNING: Unbounded memory usage for #{uri}" unless @span || @limit
  end

  def run
    @ili.watch @uri do |message|
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
