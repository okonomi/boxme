require "bundler/setup"
Bundler.require(:default)

require_relative "lib/boxme/server"
require_relative "lib/boxme/commands/login"

case ARGV[0]
when "login"
  Boxme::Commands::Login.new.call
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
