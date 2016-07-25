require 'thor'

module Capsens
  module Codecom
    class CLI < Thor
      desc :start, "starts engine to add missing comments"
      option :force

      def start
        Capsens::Codecom::Runner.new(options[:force])
      end
    end
  end
end