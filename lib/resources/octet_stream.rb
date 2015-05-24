module Intelligentli

  class OctetStream

    def initialize(server, name:)
      @server = server
      @name   = name
    end

    def data=(data, geometry: nil, tags: nil)
      return unless @name

      octet_stream = {
        name: @name,
        time_precision: 's', # fixme
        data: data
      }
      octet_stream[:geometry] = geometry if geometry
      octet_stream[:tags]     = tags if tags

      @server.multi_post("/api/v2/octet_streams", { octet_streams: [octet_stream] }.to_json )
    end

  end

end
