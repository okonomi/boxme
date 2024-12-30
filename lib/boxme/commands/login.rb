require "launchy"
require "net/http"
require "securerandom"
require "uri"

require_relative "../server"

module Boxme
  class Commands
    class Login
      def call
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
      end
    end
  end
end
