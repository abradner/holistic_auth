require 'spec_helper'

describe Authinator::EndPointListener do
  before :all do
    @creds_hash = {
        email: 'test@foogi.me',
        auth_code: '4/auth_code',
        provider: 'google',
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
    listener1 = Authinator::EndPointListener.new(@creds_hash.dup.tap { |hs| hs.delete(:email) }) # remove email
    listener2 = Authinator::EndPointListener.new(@creds_hash.dup.tap { |hs| hs.delete(:auth_code) }) # remove ac
    listener3 = Authinator::EndPointListener.new(@creds_hash.dup.tap { |hs| hs.delete(:provider) }) # remove prov

    expect(listener1.valid?).to be_falsey
    expect(listener2.valid?).to be_falsey
    expect(listener3.valid?).to be_falsey
  end
  it 'should reject invalid emails' do
    bad_email_hash1 = @creds_hash.merge(email: 'abc')
    bad_email_hash2 = @creds_hash.merge(email: '')
    bad_email_hash3 = @creds_hash.merge(email: 'a@')

    listener1 = Authinator::EndPointListener.new(bad_email_hash1)
    listener2 = Authinator::EndPointListener.new(bad_email_hash2)
    listener3 = Authinator::EndPointListener.new(bad_email_hash3)

    expect(listener1.valid?).to be_falsey
    expect(listener2.valid?).to be_falsey
    expect(listener3.valid?).to be_falsey
  end

  it 'should reject invalid providers' do
    bad_provider_hash1 = @creds_hash.merge(provider: 'some_fake_provider')
    bad_provider_hash2 = @creds_hash.merge(provider: '')

    listener1 = Authinator::EndPointListener.new(bad_provider_hash1)
    listener2 = Authinator::EndPointListener.new(bad_provider_hash2)

    expect(listener1.valid?).to be_falsey
    expect(listener2.valid?).to be_falsey
  end

end
