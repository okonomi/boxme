require "bundler/setup"
Bundler.require(:default)

require_relative "lib/boxme/server"
require_relative "lib/boxme/commands/login"
require_relative "lib/boxme/commands/user"

case ARGV[0]
when "login"
  Boxme::Commands::Login.new("http://localhost:3000/callback").call
when "user"
  Boxme::Commands::User.new.call
else
  puts "Usage: boxme [login|user]"
end
