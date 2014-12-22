module Authinator
  class EndPointListener
    attr_reader :email, :provider, :auth_code, :options, :errors

    def initialize(hash = {})
      @email = hash.delete :email
      @provider = hash.delete :provider
      @auth_code = hash.delete :auth_code
      @options = hash
      @errors = []
    end

    def valid?
      validator_presence? &&
        validator_valid_email? &&
        validator_valid_provider?
    end

  private

    def validator_presence?
      email_present = present? @email
      provider_present = present? @provider
      auth_code_present = present? @auth_code

      return true if email_present && provider_present && auth_code_present
      errors << 'A required param is missing'
      errors << '"email" field missing' unless email_present
      errors << '"provider" field missing' unless provider_present
      errors << '"auth_code" field missing' unless auth_code_present
      false
    end

    # Regexp lovingly borrowed from https://github.com/balexand/email_validator
    def validator_valid_email?
      name_validation = @options[:strict_mode] ? '-a-z0-9+._' : '^@\\s'
      regexp = /\A\s*([#{name_validation}]{1,64})@((?:[-a-z0-9]+\.)+[a-z]{2,})\s*\z/i
      return true if @email =~ regexp
      errors << "Email '#{@email}' is invalid"
      false
    end

    def validator_valid_provider?
      return true if Authinator::AuthCodeExchanger.valid_providers.include? @provider.to_sym
      errors << "Provider '#{@provider}' is invalid"
      false
    end

    # recreate rails method
    def present?(el)
      !blank?(el)
    end

    def blank?(el)
      el.nil? || el.empty?
    end
  end
end
