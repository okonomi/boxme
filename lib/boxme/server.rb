# frozen_string_literal: true

require "socket"
require "uri"

module Boxme
  class Server
    attr_reader :code

    def initialize(state)
      @state = state
      @code = nil
    end

    def start
      server = TCPServer.new 3000
      loop do
        client = server.accept
        input = client.gets
        puts input
        next unless input

        request = parse_request(input)
        response = handle(request)

        client.puts response
        client.close

        return @code if @code
      end
    end

    private

    def parse_request(input)
      method, path, version = input.split
      uri = URI.parse(path)
      {
        version: version,
        method: method,
        path: uri.path,
        query: URI.decode_www_form(uri.query || "").to_h
      }
    end

    def handle(request)
      case request.values_at(:method, :path)
      in ["GET", "/callback"]
        if request[:query]["state"] == @state
          @code = request[:query]["code"]

          <<~RESPONSE
            HTTP/1.1 200 OK
            Content-Type: text/html

            <html>
              <body>
                <h1>Boxme</h1>
                <p>Authorization successful</p>
              </body>
            </html>
          RESPONSE
        else
          <<~RESPONSE
            HTTP/1.1 400 OK
            Content-Type: text/html

            <html>
              <body>
                <h1>Boxme</h1>
                <p>Authorization failed.</p>
              </body>
            </html>
          RESPONSE
        end
      else
        <<~RESPONSE
          HTTP/1.1 404 Not Found
          Content-Type: text/html

          <html>
            <body>
              <h1>Boxme</h1>
              <p>Not Found</p>
            </body>
          </html>
        RESPONSE
      end
    end
  end
end
