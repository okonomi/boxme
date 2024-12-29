require "bundler/setup"
Bundler.require(:default)

require "securerandom"
require "socket"

module Boxme
  class Server
    def start
      server = TCPServer.new 3000
      while session = server.accept
        request = session.gets
        puts request

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
        return
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

  server = Thread.new do
    Boxme::Server.new.start
  end

  base_url = "https://app.box.com/api/oauth2/authorize"
  redirect_uri = "http://localhost:3000/callback"
  response_type = "code"
  state = SecureRandom.hex(32)
  authorization_url = "#{base_url}?client_id=#{client_id}&response_type=#{response_type}&state=#{state}&redirect_uri=#{redirect_uri}"

  Launchy.open(authorization_url)

  server.join
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
