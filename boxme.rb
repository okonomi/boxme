require "bundler/setup"

case ARGV[0]
when "login"
  puts "Login to Box"

  print "Enter your client ID: "
  client_id = STDIN.gets.chomp

  print "Enter your client secret: "
  client_secret = STDIN.gets.chomp
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
