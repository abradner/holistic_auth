module Authinator
  # Exception to handle a missing initializer
  # class MissingConfiguration < StandardError
  #   def initialize
  #     super('Configuration for authinator missing. Do you have an Authinator initializer?')
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
      @providers = {}
      add_provider(
        :stub,
        client_id: 'cl_id',
        client_secret: 'cl_sec',
        site: 'https://example.org',
        token_url: '/extoken',
        api_key: 'api_key',
        user_info_url: 'http://example.org/info',
      )
      add_provider(
        :google,
        site: 'https://accounts.google.com',
        token_url: '/o/oauth2/token',
        user_info_url: 'https://www.googleapis.com/plus/v1/people/me/openIdConnect',
      )
    end

    def providers
      @providers.keys
    end

    def add_provider(provider_name, options = {})
      @providers[provider_name] = Provider.new(provider_name, options)
    end

    def add_secrets(provider_name, options = {})
      fail(
        ArgumentError,
        "#{provider_name} is not a configured provider.\n" \
        "Valid Providers:\n" <<
        providers.to_s,
      ) if @providers[provider_name].blank?

      @providers[provider_name].add_secrets(options)
    end

    # A more abstracted way of accessing the providers
    def provider_for(provider_name)
      @providers[provider_name]
    end
  end
end
