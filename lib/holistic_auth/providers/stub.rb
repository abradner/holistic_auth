module HolisticAuth
  module Providers
    class Stub < GenericProvider
      SETTINGS = {
        client_id: 'stub_cl_id',
        client_secret: 'stub_cl_sec',
        site: 'https://example.org',
        token_url: '/extoken',
        api_key: 'api_key',
        user_info_url: 'http://example.org/info',
      }

      STUB_SAMPLE_TOKEN = {
        token: 'ya29.token',
        refresh_token: '1/refresh',
        expires_in: 3600,
      }

      def initialize(options = {})
        super(options)

        @client_id ||= settings[:client_id]
        @client_secret ||= settings[:client_secret]
        @api_key ||= settings[:api_key]
      end

      def settings
        SETTINGS
      end

      def exchange(_, __)
        @client = OAuth2::Client.new(
          client_id,
          client_secret,
        )

        OAuth2::AccessToken.new(
          @client,
          STUB_SAMPLE_TOKEN[:token],
          refresh_token: STUB_SAMPLE_TOKEN[:refresh_token],
          expires_in: STUB_SAMPLE_TOKEN[:expires_in],
        )
      end
    end
  end
end
