require 'oauth2'

module Authinator
  class AuthCodeExchanger
    STUB_SAMPLE_TOKEN = {
      token: 'ya29.token',
      refresh_token: '1/refresh',
      expires_in: 3600,
    }

    attr_reader :provider
    # attr_reader :client

    def self.valid_providers
      Authinator.configuration.providers
    end

    def initialize(provider, _client_options = {})
      @provider = provider
    end

    def site_token_url
      @provider.site + @provider.token_url
    end

    def exchange(auth_code)
      # auth_code = params[:code]
      return if auth_code.nil? || auth_code.empty?

      case @provider.name
      when :google
        exchange_with_google(auth_code)
      when :stub
        exchange_with_stub(auth_code)
      end
    end

  private

    # def build_provider_hash(client_options)
    #   @provider_hash = Authinator.configuration.provider_for[@provider.to_sym]
    #   @provider_hash[:client_id] = client_options.delete(:client_id) if client_options[:client_id]
    #   @provider_hash[:client_secret] = client_options.delete(:client_secret) if client_options[:client_secret]
    # end

    def exchange_with_google(code)
      @client = OAuth2::Client.new(@provider.client_id, @provider.client_secret, @provider.to_hash)

      token = @client.auth_code.get_token(code, redirect_uri: 'http://localhost:4200')

      # response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
      # response.class.name
      # => OAuth2::Response

      token
    end

    def exchange_with_stub(_code)
      @client = OAuth2::Client.new(
          @provider.client_id,
          @provider.client_secret,
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
