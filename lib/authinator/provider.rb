module Authinator
  class Provider
    attr_reader :name
    attr_accessor :client_id,
                  :client_secret,
                  :site,
                  :token_url,
                  :api_key

    def initialize(name)
      @name = name
    end

    def secrets
      { client_id: @client_id, client_secret: @client_secret }
    end

    def add_provider(provider, secrets = {})
      @secrets[provider.to_sym] = secrets unless secrets.blank?
    end

    alias_method :inspect, :to_hash
    def to_hash
      {
        name: @name,
        client_id: @client_id,
        client_secret: @client_secret,
        site: @site,
        token_url: @token_url,
        api_key: @api_key,
      }
    end
  end
end
