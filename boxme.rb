require "bundler/setup"

require_relative "lib/boxme/cli"

Boxme::CLI.new(ARGV).run
