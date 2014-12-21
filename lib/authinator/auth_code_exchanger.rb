# require 'omniauth/strategies/google_oauth2'
# require 'omniauth-oauth2'
require 'oauth2'

# module Authinator
class AuthCodeExchanger
  VALID_PROVIDERS = %i(stub google)

  def self.valid_providers
    VALID_PROVIDERS
  end
  attr_reader :provider

  @env_hash = {
    provider_ignores_state: true,
    code: '4/def',
    callback_path: 'https://callback_path',
    client_options: { site: 'https://api.somesite.com' },
    site: 'https://accounts.google.com',
    token_url: '/o/oauth2/token'
  }

  PROVIDER_HASHES = {
    google: {
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://accounts.google.com',
      token_url: '/o/oauth2/token'
    },
    stub: {
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://example.org',
      token_url: '/extoken'
    }
  }

  def initialize(provider)
    @provider = provider
    @provider_hash = PROVIDER_HASHES[provider]
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

  def site_token_url
    @provider_hash[:site] + @provider_hash[:token_url]
  end

  private

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
        @provider_hash[:client_secret]
    )

    OAuth2::AccessToken.new(
        @client,
        'ya29.token',
        refresh_token: '1/refresh',
        expires_in: 3600
    )
  end
end
# end
