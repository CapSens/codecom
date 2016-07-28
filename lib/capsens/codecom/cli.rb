require 'thor'

module Capsens
  module Codecom
    class CLI < Thor
      default_task :start
      desc :start, "starts engine to add missing comments"
      option :force

      # Describe here what the method should be used for.
      # Remember to add use case examples if possible.
      #
      # @author Yassine Zenati
      #
      # Examples:
      #
      #   start
      #   #=> @return Expected returned value
      #
      # @return [Class] Describe what the method should return.
      def start
        Capsens::Codecom::Runner.new(options[:force])
      end
    end
  end
end