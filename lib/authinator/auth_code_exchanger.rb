# require 'omniauth/strategies/google_oauth2'
# require 'omniauth-oauth2'
require 'oauth2'

module Authinator
  class AuthCodeExchanger
    VALID_PROVIDERS = [:stub, :google]
    STUB_SAMPLE_TOKEN = {
      token: 'ya29.token',
      refresh_token: '1/refresh',
      expires_in: 3600,
    }

    attr_reader :provider
    # attr_reader :client

    def self.valid_providers
      VALID_PROVIDERS
    end

    PROVIDER_HASHES = {
      google: {
        client_id: 'cl_id',
        client_secret: 'cl_sec',
        site: 'https://accounts.google.com',
        token_url: '/o/oauth2/token',
      },
      stub: {
        client_id: 'cl_id',
        client_secret: 'cl_sec',
        site: 'https://example.org',
        token_url: '/extoken',
      },
    }

    def initialize(provider, client_options = {})
      unless VALID_PROVIDERS.include? provider
        fail ArgumentError,
             "Provider #{provider} not in supported parameter list:\n" <<
               VALID_PROVIDERS.inspect
      end

      @provider = provider
      build_provider_hash(client_options)
    end

    def site_token_url
      @provider_hash[:site] + @provider_hash[:token_url]
    end

    def exchange(auth_code)
      # auth_code = params[:code]
      return if auth_code.nil? || auth_code.empty?

      case @provider.to_sym
      when :google
        exchange_with_google(auth_code)
      when :stub
        exchange_with_stub(auth_code)
      end
    end

  private

    def build_provider_hash(client_options)
      @provider_hash = PROVIDER_HASHES[@provider.to_sym]
      @provider_hash[:client_id] = client_options.delete(:client_id) if client_options[:client_id]
      @provider_hash[:client_secret] = client_options.delete(:client_secret) if client_options[:client_secret]
    end

    def exchange_with_google(code)
      provider_hash = @provider_hash.dup

      client_id = provider_hash.delete(:client_id)
      client_secret = provider_hash.delete(:client_secret)
      @client = OAuth2::Client.new(client_id, client_secret, provider_hash)

      token = @client.auth_code.get_token(code)

      # response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
      # response.class.name
      # => OAuth2::Response

      token
    end

    def exchange_with_stub(_code)
      @client = OAuth2::Client.new(
          @provider_hash[:client_id],
          @provider_hash[:client_secret],
      )

      OAuth2::AccessToken.new(
          @client,
          STUB_SAMPLE_TOKEN[:token],
          refresh_token: STUB_SAMPLE_TOKEN[:refresh_token],
          expires_in: STUB_SAMPLE_TOKEN[:expires_in],
      )
    end
  end
end
