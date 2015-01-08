module Authinator
  class Provider
    attr_reader :name
    attr_accessor :client_id,
                  :client_secret,
                  :site,
                  :token_url,
                  :api_key,
                  :user_info_url

    def initialize(name, options = {})
      @name = name
      @client_id = options.delete :client_id
      @client_secret = options.delete :client_secret
      @site = options.delete :site
      @token_url = options.delete :token_url
      @api_key = options.delete :api_key
      @user_info_url = options.delete :user_info_url
    end

    def add_secrets(options = {})
      @client_id = options.delete :client_id if options[:client_id]
      @client_secret = options.delete :client_secret if options[:client_secret]
      @api_key = options.delete :api_key if options[:api_key]
    end

    def secrets
      sec = {}
      sec[:client_id] = @client_id if @client_id
      sec[:client_secret] = @client_secret if @client_secret
      sec[:api_key] = @api_key if @api_key

      sec
    end

    def to_hash
      {
        name: @name,
        client_id: @client_id,
        client_secret: @client_secret,
        site: @site,
        token_url: @token_url,
        api_key: @api_key,
        user_info_url: @user_info_url,
      }
    end

    def empty?
      to_hash.empty?
    end

    alias_method :inspect, :to_hash
  end
end
