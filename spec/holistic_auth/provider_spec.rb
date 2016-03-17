require 'spec_helper'
require 'json'

describe 'Providers' do
  before :all do
    @secrets = {
      client_id: ((0...50).map { ('a'..'z').to_a[rand(26)] }.join),
      client_secret: ((0...50).map { ('a'..'z').to_a[rand(26)] }.join),
      tenant_id: ((0...50).map { ('a'..'z').to_a[rand(26)] }.join),
    }

    HolisticAuth.configure do |config|
      config.add_secrets :google,
                         client_id: @secrets[:client_id],
                         client_secret: @secrets[:client_secret]
    end
    @token_hash = {
      access_token: 'ya29.token',
      refresh_token: '1/refresh',
      expires_in: 3600,
      token_type: 'Bearer',
    }
    @test_env = {
      client_id: @secrets[:client_id],
      client_secret: @secrets[:client_secret],
      code: '4/code',
      grant_type: 'authorization_code',
      redirect_uri: 'http://localhost:4200',
    }

    @req_headers = {
      accept: '*/*',
      content_type: 'application/x-www-form-urlencoded',
    }

    @req_response = {
      status: 200,
      body: @token_hash.to_json,
      headers: { content_type: 'application/json' },
    }

    @stub_provider = HolisticAuth::Providers::Stub.new(
      client_id: @secrets[:client_id],
      client_secret: @secrets[:client_secret],
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )
    @google_provider = HolisticAuth::Providers::Google.new(
      client_id: @secrets[:client_id],
      client_secret: @secrets[:client_secret],
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )
  end

  describe 'exchange' do
    it 'should correctly process a generic (stub) token' do
      stub_request(:post, @stub_provider.site_token_url).
        with(body: @test_env,
             headers: @req_headers).
        to_return(@req_response)

      result = @stub_provider.exchange(@test_env[:code], @test_env[:redirect_uri])

      expect(result.token).to eq @token_hash[:access_token]
      expect(result.refresh_token).to eq @token_hash[:refresh_token]
      expect(result.expires_in).to eq @token_hash[:expires_in]
    end

    it 'should correctly process a google token' do
      stub_request(:post, @google_provider.site_token_url).
        with(body: @test_env,
             headers: @req_headers).
        to_return(@req_response)

      result = @google_provider.exchange(@test_env[:code], @test_env[:redirect_uri])

      expect(result.token).to eq @token_hash[:access_token]
      expect(result.refresh_token).to eq @token_hash[:refresh_token]
      expect(result.expires_in).to eq @token_hash[:expires_in]
    end

    it 'should return an AccessToken for each provider' do
      klass = OAuth2::AccessToken

      HolisticAuth.configuration.providers.each do |provider_name|
        provider = HolisticAuth.configuration.provider(provider_name)
        expect(provider).to be_kind_of HolisticAuth::Providers::GenericProvider

        provider.add_secrets(@secrets.dup)
        expect(provider.client_id).to eq @secrets[:client_id]
        expect(provider.client_secret).to eq @secrets[:client_secret]

        stub_request(:post, provider.site_token_url).
          with(body: @test_env,
               headers: @req_headers).
          to_return(@req_response)

        expect(provider.exchange(@test_env[:code], @test_env[:redirect_uri])).to be_kind_of klass
      end
    end
  end

  describe 'retreive_user_info' do
    it 'should error for the generic provider' do
    end

    it 'should return a hash with all the expected fields' do
      {
        email_verified: true,
        email: 'a@b.c',
        given_name: 'first',
        family_name: 'last',
        profile: 'xyz',
      }.with_indifferent_access
    end
  end
end
