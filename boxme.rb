require "bundler/setup"
Bundler.require(:default)

require "securerandom"
require "socket"
require "net/http"
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
        if input
          request = parse_request(input)
          response = handle(request)

          client.puts response
          client.close

          return @code if @code
        end
      end
    end

    private

    def handle(request)
      case request.values_at(:method, :path)
      in ["GET", "/callback"]
        if request[:query]["state"] == @state
          @code = request[:query]["code"]

          return <<~RESPONSE
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
          return <<~RESPONSE
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
        return <<~RESPONSE
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

    def parse_request(input)
      method, path, version = input.split(" ")
      uri = URI.parse(path)
      {
        version: version,
        method: method,
        path: uri.path,
        query: Hash[URI.decode_www_form(uri.query || "")],
      }
    end
  end
end

case ARGV[0]
when "login"
  puts "Login to Box"

  print "Enter your client ID: "
  client_id = STDIN.gets.chomp

  print "Enter your client secret: "
  client_secret = STDIN.gets.chomp

  base_url = "https://account.box.com/api/oauth2/authorize"
  redirect_uri = "http://localhost:3000/callback"
  response_type = "code"
  state = SecureRandom.hex(32)

  server = Thread.new do
    Boxme::Server.new(state).start
  end

  authorization_url = "#{base_url}?client_id=#{client_id}&response_type=#{response_type}&state=#{state}&redirect_uri=#{redirect_uri}"

  Launchy.open(authorization_url)

  server.join

  code = server.value
  puts "Authorization code: #{code}"

  puts "Exchange authorization code for access token"
  token_url = URI("https://api.box.com/oauth2/token")
  response = Net::HTTP.post_form(token_url, {
    grant_type: "authorization_code",
    code: code,
    client_id: client_id,
    client_secret: client_secret,
  })
  puts response.body
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
