module HolisticAuth
  # Exception to handle a missing initializer
  # class MissingConfiguration < StandardError
  #   def initialize
  #     super('Configuration for holistic_auth missing. Do you have an HolisticAuth initializer?')
  #   end
  # end

  # Module level methods
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # def self.configuration
  #   @config || (fail MissingConfiguration.new)
  # end

  # Configuration class
  class Configuration
    attr_reader :providers
    attr_accessor :valid_applications

    def initialize
      @providers = {
        stub: provider_for(:stub).new,
        google: provider_for(:google).new,
        ms_graph: provider_for(:ms_graph).new,
        outlook: provider_for(:outlook).new,
      }
    end

    def providers
      @providers.keys
    end

    def provider(provider_name)
      test_for_provider!(provider_name)
      @providers[provider_name]
    end

    def add_secrets(provider_name, options = {})
      test_for_provider!(provider_name)
      @providers[provider_name].add_secrets(options)
    end

  private

    def test_for_provider!(provider_name)
      raise(
        ArgumentError,
        "#{provider_name} is not a configured provider.\n" \
        "Valid Providers:\n" <<
          providers.to_s,
      ) if @providers[provider_name].nil?
    end

    # A more abstracted way of accessing the providers
    def provider_for(provider_name)
      "HolisticAuth::Providers::#{provider_name.to_s.camelize}".constantize
    end
  end
end
