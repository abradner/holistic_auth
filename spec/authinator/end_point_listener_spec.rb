require 'spec_helper'

describe Authinator::EndPointListener do
  before :each do
    @stub_provider = Authinator::Provider.new(
      :stub,
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )
    @creds_hash = {
      auth_code: '4/auth_code',
      provider: @stub_provider,
    }
  end
  it 'should accept valid-looking credentials from the client' do
    listener = Authinator::EndPointListener.new(@creds_hash)
    expect(listener.valid?).to be_truthy
  end

  # These tests extend on the test above.
  # Given the test above handles the happy path, everything below are sad path tests

  it 'should return an error to the client if the credentials were invalid' do
    bad_creds_hash = {
      a: 'b',
      c: 'd',
    }
    listener = Authinator::EndPointListener.new(bad_creds_hash)
    expect(listener.valid?).to be_falsey
  end
  it 'should return an error unless all three fields are provided' do
    listener2 = Authinator::EndPointListener.new(@creds_hash.dup.tap { |hs| hs.delete(:auth_code) }) # remove ac
    listener3 = Authinator::EndPointListener.new(@creds_hash.dup.tap { |hs| hs.delete(:provider) }) # remove prov

    expect(listener2.valid?).to be_falsey
    expect(listener3.valid?).to be_falsey
  end

  it 'should reject invalid providers' do
    bad_provider_1 = Authinator::Provider.new(
      :bad1,
      client_id: 'cl_id',
      client_secret: 'cl_sec',
      site: 'https://example.org',
      token_url: '/extoken',
      api_key: 'api_key',
      user_info_url: 'http://example.org/info',
    )

    bad_provider_2 = Authinator::Provider.new(
      :bad2,
    )

    bad_provider_hash1 = @creds_hash.merge(provider: bad_provider_1)
    bad_provider_hash2 = @creds_hash.merge(provider: bad_provider_2)

    listener1 = Authinator::EndPointListener.new(bad_provider_hash1)
    listener2 = Authinator::EndPointListener.new(bad_provider_hash2)

    expect(listener1.valid?).to be_falsey
    expect(listener2.valid?).to be_falsey
  end

  it 'should return a human-readable list of errors if there are any' do
    listener = Authinator::EndPointListener.new({})
    listener.valid?
    expect(listener.errors).to eq [
      'A required param is missing',
      '"provider" field missing',
      '"auth_code" field missing',
    ]
  end
end
