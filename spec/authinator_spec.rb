require 'spec_helper'
describe AuthCodeExchanger do
  it 'should be able to convert a generic auth token into a access_token/request token' do
    hash = {
        access_token: 'abc',
        refresh_token: 'def',
        expires: true,
        expiry: 3600
    }

    expect(AuthCodeExchanger.exchange(:stub, 'abc')).to eq hash
  end

  describe 'google' do
    before :all do
      @result = AuthCodeExchanger.exchange(:google, 'abc')
    end
    it 'should return an expected hash on completion' do

      expect(@result).to have_key :access_token
      expect(@result).to have_key :refresh_token
      expect(@result).to have_key :expires
      expect(@result).to have_key :expiry
    end

    it 'should return a VALID access token' do
      _at = @result[:access_token]
      pending 'do api query to test access token "at"'

    end
  end
end
