require "faraday"
require "json"

require "tinplate/version"
require "tinplate/configuration"
require "tinplate/tineye"
require "tinplate/search_results"
require "tinplate/errors"

module Tinplate
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
