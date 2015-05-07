require 'chronic_duration'
require_relative 'utilities'

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
    new_data = Utilities.epoch_to_time(message[:data], message[:time_precision])
    @data.concat new_data
    @data = @data.sort_by { |point| point[:time] }
    @data = @data.reject  { |point| point[:time] < Time.now - @span } if @span
    @data = @data[-@limit..-1] if @limit && @data.length > @limit
  end

end
