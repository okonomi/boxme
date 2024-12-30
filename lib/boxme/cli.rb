# frozen_string_literal: true

require_relative "server"
require_relative "commands/login"
require_relative "commands/user"

module Boxme
  class CLI
    def initialize(args)
      @args = args
    end

    def run
      case @args[0]
      when "login"
        Boxme::Commands::Login.new.call
      when "user"
        Boxme::Commands::User.new.call
      else
        puts "Usage: boxme [login|user]"
      end
    end
  end
end
