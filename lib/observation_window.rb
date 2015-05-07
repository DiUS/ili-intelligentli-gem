require 'chronic_duration'

class ObservationWindow

  attr_reader :data

  def initialize span: nil, limit: nil
    @span  = span ? ChronicDuration.parse(span) : nil
    @limit = limit
    @data  = []
    raise "Unbounded memory usage!  Please specify span or limit." unless @span || @limit
  end

  def concat new_data
    @data = @data.concat(new_data).sort_by { |point| point[:time] }
    @data = @data.reject { |point| point[:time] < Time.now - @span } if @span
    @data = @data.last(@limit) if @limit
    @data
  end

end
