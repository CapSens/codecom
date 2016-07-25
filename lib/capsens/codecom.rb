require 'capsens/codecom/version'
require 'capsens/runner'
require 'securerandom'
require 'fileutils'
require 'tempfile'

module Capsens
  module Codecom
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :ignored_methods
      attr_accessor :force_regeneration

      def initialize
        @ignored_methods    ||= [ :initialize, :permitted_params ]
        @force_regeneration ||= false
      end
    end
  end
end
