module Authinator
  # Exception to handle a missing initializer
  class MissingConfiguration < StandardError
    def initialize
      super('Configuration for authinator missing. Do you have an Authinator initializer?')
    end
  end

  # Module level methods
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.configuration
    @config || (fail MissingConfiguration.new)
  end

  # Configuration class
  class Configuration
    attr_accessor :provider_secrets

    def initialize
      @mailer_sender = {

      }
    end
  end
end
