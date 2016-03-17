module HolisticAuth
  module Providers
    require 'oauth2'

    class GenericProvider
      attr_accessor :client_id,
                    :client_secret,
                    :site,
                    :tenant_id,
                    :token_url,
                    :api_key,
                    :user_info_url

      attr_reader :oauth2_client

      def initialize(options = {})
        @client_id = options.delete :client_id
        @client_secret = options.delete :client_secret
        @site = options.delete(:site) || settings[:site]
        @token_url = options.delete(:token_url) || settings[:token_url]
        @api_key = options.delete :api_key
        @user_info_url = options.delete(:user_info_url) || settings[:user_info_url]
        @additional_parameters = options.delete(:additional_parameters) || settings[:additional_parameters] || {}
      end

      def add_secrets(options = {})
        @client_id = options.delete :client_id if options[:client_id]
        @client_secret = options.delete :client_secret if options[:client_secret]
        @api_key = options.delete :api_key if options[:api_key]
        @tenant_id = options.delete :tenant_id if options[:tenant_id]
        @additional_parameters.merge!(options.delete :additional_parameters) if options[:additional_parameters]
      end

      def settings
        {}
      end

      def secrets
        sec = {}
        sec[:client_id] = @client_id if @client_id
        sec[:client_secret] = @client_secret if @client_secret
        sec[:api_key] = @api_key if @api_key

        sec
      end

      def exchange(auth_code, redirect_uri)
        errors = []
        errors << 'auth_code missing' if auth_code.blank?
        errors << 'redirect_uri missing' if redirect_uri.blank?
        errors << 'Client ID not set' if client_id.blank?
        errors << 'Client Secret not set' if client_secret.blank?

        fail "Cannot exchange auth code:\n#{errors}" if errors.present?

        @oauth2_client = OAuth2::Client.new(client_id, client_secret, to_hash)
        @oauth2_client.auth_code.get_token(auth_code, redirect_uri: redirect_uri)
      end

      def retrieve_user_info(*_params)
        fail 'Not implemented'
      end

      def name(*_params)
        fail 'Generic provider doesn\'t have a name'
      end

      def full_site_url
        fail "site not specified for class #{self}" unless site.present?
        site
      end

      def site_token_url
        full_site_url + token_url
      end

      def to_hash
        {
          client_id: @client_id,
          client_secret: @client_secret,
          site: full_site_url,
          token_url: @token_url,
          api_key: @api_key,
          user_info_url: @user_info_url,
          additional_parameters: @additional_parameters,
        }
      end

      def present?
        !empty?
      end

      def empty?
        site.nil? || token_url.nil?
      end

      alias_method :inspect, :to_hash
    end
  end
end
