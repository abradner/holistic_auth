module HolisticAuth
  module Providers
    class Google < GenericProvider
      SETTINGS = {
        site: 'https://accounts.google.com',
        token_url: '/o/oauth2/token',
        user_info_url: 'https://www.googleapis.com/plus/v1/people/me/openIdConnect',
      }

      def settings
        SETTINGS
      end

    end
  end
end
