require "bundler/setup"

case ARGV[0]
when "login"
  puts "Login to Box"
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
