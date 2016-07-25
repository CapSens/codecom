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







    # Describe here what the method should be used for.
    # Remember to add use case examples if possible.
    #
    # @author Yassine Zenati
    #
    # Examples:
    #
    #   self.configure
    #   #=> @return Expected returned value
    #
    # @return [Class] Describe what the method should return.
    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
    end
  end
end
