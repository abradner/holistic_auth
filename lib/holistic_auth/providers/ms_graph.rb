module HolisticAuth
  module Providers
    class MsGraph < GenericProvider
      SETTINGS = {
        site: 'https://login.microsoftonline.com',
        token_url: 'oauth2/token',
        user_info_url: 'https://graph.microsoft.com/v1.0/me',
        additional_parameters: {
          resource: 'https://graph.microsoft.com/'
        }
      }

      def settings
        SETTINGS
      end

      def full_site_url
        fail 'tenant ID not set' unless tenant_id.present?
        site + '/' + tenant_id + '/'
      end

    end
  end
end
