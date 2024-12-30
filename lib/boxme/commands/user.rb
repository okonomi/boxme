# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "xdg"

module Boxme
  class Commands
    class User
      USER_URL = URI("https://api.box.com/2.0/users/me").freeze

      def call
        puts "Show user information"

        token_info = load_token_info
        p token_info

        get_current_user(token_info)
      end

      private

      def load_token_info
        path = XDG::Config.new.home.join("boxme", "token.json")
        token_info = JSON.parse(path.read) if path.file?

        raise "No token found. Please login first" unless token_info

        token_info
      end

      def get_current_user(token_info)
        http = Net::HTTP.new(USER_URL.host, USER_URL.port)
        http.use_ssl = USER_URL.scheme == "https"

        headers = { authorization: "Bearer #{token_info["access_token"]}" }
        response = http.get(USER_URL.path, headers)

        pp JSON.parse(response.body)
      end
    end
  end
end
