require 'spec_helper'

describe HolisticAuth::ClientTokenIssuer do
  before :all do
    HolisticAuth.configure do |config|
      # config.add_secrets :google,
      #                    client_id: Rails.application.secrets.google_oauth2['client_id'],
      #                    client_secret: Rails.application.secrets.google_oauth2['client_secret']
      #
      # config.add_secrets :ms_graph,
      #                    tenant_id: Rails.application.secrets.ms_graph_oauth2['tenant_id'],
      #                    client_id: Rails.application.secrets.ms_graph_oauth2['client_id'],
      #                    client_secret: Rails.application.secrets.ms_graph_oauth2['client_secret']
      config.valid_applications = %i(ios_v1 ember_v1)
    end
  end

  it 'should exchange client-provided credentials for auth codes'
  it 'should gracefully handle and return error condition if client-provided credentials are invalid'
  it 'should verify that the tokens belong to the provided email before returning them'
  it 'should generate our own set of tokens for the client if the provided ones exchanged successfully'

  it 'should all integrate to follow a standard flow to auth the api client'

  it 'should gracefully not allow unsupported providers' do
    expect do
      HolisticAuth::ClientTokenIssuer.new(provider: :some_fake_provider)
    end.to raise_error(ArgumentError)
  end

  it 'should allow supported providers' do
    expect do
      HolisticAuth::ClientTokenIssuer.new(provider: :google)
    end.not_to raise_error()
  end

  it 'should correctly handle client information provided as a parameter' do
    pending
    ace = HolisticAuth::ClientTokenIssuer.new(provider: :google, client_id: 'new_id', client_secret: 'new_secret')

    stub_request(:post, ace.site_token_url).
      with(body: @test_env.merge(client_id: 'new_id', client_secret: 'new_secret'),
           headers: @req_headers).
      to_return(@req_response)
  end
end
