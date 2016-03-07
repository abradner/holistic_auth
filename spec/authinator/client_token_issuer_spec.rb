describe HolisticAuth::ClientTokenIssuer do
  it 'should exchange client-provided credentials for auth codes'
  it 'should gracefully handle and return error condition if client-provided credentials are invalid'
  it 'should verify that the tokens belong to the provided email before returning them'
  it 'should generate our own set of tokens for the client if the provided ones exchanged successfully'

  it 'should all integrate to follow a standard flow to auth the api client'

  it 'should gracefully not allow unsupported providers' do
    pending
    expect do
      HolisticAuth::AuthCodeExchanger.new(:some_fake_provider)
    end.to raise_error(ArgumentError)
  end

  it 'should correctly handle client information provided as a parameter' do
    pending
    ace = HolisticAuth::AuthCodeExchanger.new(:google, client_id: 'new_id', client_secret: 'new_secret')

    stub_request(:post, ace.site_token_url).
      with(body: @test_env.merge(client_id: 'new_id', client_secret: 'new_secret'),
           headers: @req_headers).
      to_return(@req_response)
  end
end
