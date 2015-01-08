module Authinator
  class EndPointListener
    attr_reader :provider, :auth_code, :options, :errors

    def initialize(hash = {})
      @provider = hash.delete :provider
      @auth_code = hash.delete :auth_code
      @options = hash
      @errors = []
    end

    def valid?
      validator_presence? &&
        validator_valid_provider?
    end

  private

    def validator_presence?
      provider_present = present? @provider
      auth_code_present = present? @auth_code

      return true if provider_present && auth_code_present
      errors << 'A required param is missing'
      errors << '"provider" field missing' unless provider_present
      errors << '"auth_code" field missing' unless auth_code_present
      false
    end

    def validator_valid_provider?
      return true if Authinator.configuration.providers.include? @provider.name
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
