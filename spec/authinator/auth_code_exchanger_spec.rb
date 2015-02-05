require 'spec_helper'
require 'json'

describe Authinator::AuthCodeExchanger do
  before :all do
    Authinator.configure do |config|
      config.add_secrets :google,
                         client_id: 'cl_id',
                         client_secret: 'cl_sec'
    end
    @token_hash = {
      access_token: 'ya29.token',
      refresh_token: '1/refresh',
      expires_in: 3600,
      token_type: 'Bearer',
    }
    @test_env = {
      client_id: 'cl_id',
      client_secret: 'cl_sec',
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

    @stub_provider = Authinator::Provider.new(
      :stub,
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )
    @google_provider = Authinator::Provider.new(
      :stub,
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )
  end

  it 'should correctly process a generic (stub) token' do
    ace = Authinator::AuthCodeExchanger.new(@stub_provider)
    stub_request(:post, ace.site_token_url).
      with(body: @test_env,
           headers: @req_headers).
      to_return(@req_response)

    result = ace.exchange(@test_env[:code], @test_env[:redirect_uri])

    expect(result.token).to eq @token_hash[:access_token]
    expect(result.refresh_token).to eq @token_hash[:refresh_token]
    expect(result.expires_in).to eq @token_hash[:expires_in]
  end

  it 'should return an AccessToken for each provider' do
    klass = OAuth2::AccessToken

    Authinator::AuthCodeExchanger.valid_providers.each do |provider_name|
      provider = Authinator.configuration.provider_for provider_name
      ace = Authinator::AuthCodeExchanger.new(provider)
      stub_request(:post, ace.site_token_url).
        with(body: @test_env,
             headers: @req_headers).
        to_return(@req_response)

      expect(ace.exchange(@test_env[:code], @test_env[:redirect_uri])).to be_a klass
    end
  end

  it 'should correctly process a google token' do
    ace = Authinator::AuthCodeExchanger.new(@google_provider)
    stub_request(:post, ace.site_token_url).
      with(body: @test_env,
           headers: @req_headers).
      to_return(@req_response)

    result = ace.exchange(@test_env[:code], @test_env[:redirect_uri])

    expect(result.token).to eq @token_hash[:access_token]
    expect(result.refresh_token).to eq @token_hash[:refresh_token]
    expect(result.expires_in).to eq @token_hash[:expires_in]
  end
end
