require 'capsens/codecom/version'
require 'capsens/codecom/cli'
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
    end
  end
end
