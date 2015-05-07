module Utilities

  def self.epoch_to_time(data, precision)
    divisor = { 'us' => 1000000, 'ms' => 1000 }[precision] || 1
    data.map { |point| point.update(time: Time.at(point[:time]/divisor)) }
  end

end
