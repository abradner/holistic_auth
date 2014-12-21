require 'spec_helper'
require 'json'

describe AuthCodeExchanger do
  before :all do
    @token_hash = {
      access_token: 'ya29.token',
      refresh_token: '1/refresh',
      expires_in: 3600,
      token_type: 'Bearer'
    }
    @test_env = {
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      code: '4/code',
      grant_type: 'authorization_code'
    }

    @req_headers = {
      accept: '*/*',
      accept_encoding: 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      content_type: 'application/x-www-form-urlencoded',
      user_agent: 'Faraday v0.9.0'
    }

    @req_response = {
      status: 200,
      body: @token_hash.to_json,
      headers: { content_type: 'application/json' }
    }
  end
  it 'should correctly process a generic (stub) token' do
    ace = AuthCodeExchanger.new(:stub)
    stub_request(:post, ace.site_token_url)
      .with(body: @test_env,
            headers: @req_headers)
      .to_return(@req_response)

    result = ace.exchange(@test_env[:code])

    expect(result.token).to eq @token_hash[:access_token]
    expect(result.refresh_token).to eq @token_hash[:refresh_token]
    expect(result.expires_in).to eq @token_hash[:expires_in]
  end

  it 'should return an AccessToken for each provider' do
    klass = OAuth2::AccessToken

    AuthCodeExchanger.valid_providers.each do |provider|
      ace = AuthCodeExchanger.new(provider)
      stub_request(:post, ace.site_token_url)
        .with(body: @test_env,
              headers: @req_headers)
        .to_return(@req_response)

      expect(ace.exchange(@test_env[:code])).to be_a klass
    end
  end

  it 'should correctly process a google token' do
    ace = AuthCodeExchanger.new(:google)
    stub_request(:post, ace.site_token_url)
      .with(body: @test_env,
            headers: @req_headers)
      .to_return(@req_response)

    result = ace.exchange(@test_env[:code])

    expect(result.token).to eq @token_hash[:access_token]
    expect(result.refresh_token).to eq @token_hash[:refresh_token]
    expect(result.expires_in).to eq @token_hash[:expires_in]
  end

  it 'should gracefully not allow unsupported providers' do
    expect do
      AuthCodeExchanger.new(:some_fake_provider)
    end.to raise_error(ArgumentError)
  end
end
