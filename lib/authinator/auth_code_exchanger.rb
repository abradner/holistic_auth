# module Authinator
class AuthCodeExchanger
  def self.exchange(provider, auth_code)
    # auth_code = params[:code]
    return if auth_code.nil? || auth_code.empty?

    case provider.to_sym
      when :google
        exchange_with_google(auth_code)
      when :stub
        exchange_with_stub(auth_code)
    end
  end

  private

  def self.exchange_with_google(_code)
    {
        access_token: 'abc',
        refresh_token: 'def',
        expires: true,
        expiry: 3600
    }
  end

  def self.exchange_with_stub(_code)
    {
        access_token: 'abc',
        refresh_token: 'def',
        expires: true,
        expiry: 3600
    }
  end
end
# end
