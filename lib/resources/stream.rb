module Intelligentli

  class Stream

    def initialize(server, id: nil, name: nil)
      @server = server
      @id     = id if id
      @name   = name if name
      raise 'Please supply id or name, but not both' unless (@id || @name) && !(@id && @name)
    end

    def data(function: nil, group: nil, start_time: nil, end_time: nil, time_precision: 's')
      return unless @id

      query = []
      if function && group
        query << "function=#{function}"
        query << "group=#{group}"
      end
      if start_time && end_time && time_precision
        query << "start_time=#{start_time}"
        query << "end_time=#{end_time}"
        query << "time_precision=#{time_precision}"
      end
      query_string = query.empty? ? '' : "?#{query.join('&')}"

      @server.get("/api/v2/streams/#{@id}#{query_string}")[:stream][:data]
    end

    def data=(data, geometry: nil, tags: nil)
      return unless @name

      stream = {
        name: @name,
        time_precision: 's', # fixme
        data: data
      }
      stream[:geometry] = geometry if geometry
      stream[:tags]     = tags if tags

      self.class.post(@server, { streams: [stream] })
    end

    def watch(&block)
      return unless @id
      @server.watch("/api/v2/firehose/streams/#{@id}", &block)
    end

    class << self
      def find_by(server, tag: nil, latitude: nil, longitude: nil, distance: nil)
        query = []
        query << "tag=#{tag.split(' ').join('+')}" if tag
        if distance && latitude && longitude
          query << "distance=#{distance}"
          query << "latitude=#{latitude}"
          query << "longitude=#{longitude}"
        end
        query_string = query.empty? ? '' : "?#{query.join('&')}"
        server
          .get("/api/v2/streams#{query_string}")[:streams]
          .map { |stream| new(server, id: stream[:id]) }
      end

      def post(server, streams)
        server.post("/api/v2/streams", streams.to_json)
      end
    end

  end

end
