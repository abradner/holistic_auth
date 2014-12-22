describe Authinator::ClientTokenIssuer do
  it 'should exchange client-provided credentials for auth codes'
  it 'should gracefully handle and return error condition if client-provided credentials are invalid'
  it 'should verify that the tokens belong to the provided email before returning them'
  it 'should generate our own set of tokens for the client if the provided ones exchanged successfully'

  it 'should all integrate to follow a standard flow to auth the api client'
end
