require_relative 'utilities'
require_relative 'observation_window'

class StreamWatcher

  def initialize ili, uri, options, block
    @ili, @uri, @block = ili, uri, block
    @obs = ObservationWindow.new(options)
  end

  def run
    @ili.watch @uri do |message|
      @block.call(@obs.concat(Utilities.epoch_to_time(message[:data], message[:time_precision])))
    end
  end

end
