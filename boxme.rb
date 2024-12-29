require "bundler/setup"
Bundler.require(:default)

require "securerandom"
require "socket"
require "uri"

module Boxme
  class Server
    def initialize(state)
      @state = state
    end

    def start
      server = TCPServer.new 3000
      while session = server.accept
        request = session.gets
        puts request
        data = handle(request)

        response = <<~RESPONSE
          HTTP/1.1 200 OK
          Content-Type: text/html

          <html>
            <body>
              <h1>Boxme</h1>
              <p>Authorization successful</p>
            </body>
          </html>
        RESPONSE

        session.puts response
        session.close
        return data["code"]
      end
    end

    private

    def handle(request)
      method, path, version = request.split(" ")
      if method == "GET"
        uri = URI.parse(path)
        if uri.path == "/callback"
          query = Hash[URI.decode_www_form(uri.query)]
          if query["state"] == @state
            return query
          end
        end
      end
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
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
