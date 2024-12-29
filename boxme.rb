require "bundler/setup"
require "securerandom"
Bundler.require(:default)

case ARGV[0]
when "login"
  puts "Login to Box"

  print "Enter your client ID: "
  client_id = STDIN.gets.chomp

  print "Enter your client secret: "
  client_secret = STDIN.gets.chomp

  base_url = "https://app.box.com/api/oauth2/authorize"
  redirect_uri = "http://localhost:3000/callback"
  response_type = "code"
  state = SecureRandom.hex(32)
  authorization_url = "#{base_url}?client_id=#{client_id}&response_type=#{response_type}&state=#{state}&redirect_uri=#{redirect_uri}"

  Launchy.open(authorization_url)
when "user"
  puts "Show user information"
else
  puts "Usage: boxme [login|user]"
end
