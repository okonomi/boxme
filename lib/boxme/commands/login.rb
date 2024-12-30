require "launchy"
require "net/http"
require "securerandom"
require "uri"

require_relative "../server"

module Boxme
  class Commands
    class Login
      AUTHORIZE_URL = URI("https://account.box.com/api/oauth2/authorize").freeze
      TOKEN_URL = URI("https://api.box.com/oauth2/token").freeze

      def initialize(callback_url)
        @callback_url = callback_url
      end

      def call
        puts "Login to Box"

        state = SecureRandom.hex(32)

        client_id, client_secret = gets_oauth2_credentials

        server_thread = start_server(state)

        authorization_url = build_authorization_url(client_id: client_id, state: state, redirect_uri: @callback_url)

        Launchy.open(authorization_url.to_s)

        server_thread.join

        code = server_thread.value
        puts "Authorization code: #{code}"

        puts "Exchange authorization code for access token"
        token_info = exchange_code_for_access_token(code, client_id, client_secret)
        puts token_info
      end

      private

      def gets_oauth2_credentials
        print "Enter your client ID: "
        client_id = STDIN.gets.chomp

        print "Enter your client secret: "
        client_secret = STDIN.gets.chomp

        [client_id, client_secret]
      end

      def start_server(state)
        Thread.new do
          Boxme::Server.new(state).start
        end
      end

      def build_authorization_url(client_id:, state:, redirect_uri:)
        AUTHORIZE_URL.dup.tap do |url|
          url.query = URI.encode_www_form({
            client_id: client_id,
            response_type: "code",
            state: state,
            redirect_uri: redirect_uri,
          })
        end
      end

      def exchange_code_for_access_token(code, client_id, client_secret)
        response = Net::HTTP.post_form(TOKEN_URL, {
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
