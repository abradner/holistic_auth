module HolisticAuth
  module Providers
    class Outlook < MsGraph
      RESOURCE = 'https://outlook.office.com'.freeze
      API_VERSION = 'v2.0'.freeze

      SETTINGS = {
        site: 'https://login.microsoftonline.com',
        token_url: 'oauth2/v2.0/token',
        user_info_url: URI("#{RESOURCE}/api/#{API_VERSION}/Me"),
        additional_parameters: {
          resource: RESOURCE,
        },
      }.freeze

      def name
        :outlook
      end

      def process_info(hash)
        sanity_check!(hash)

        {
          email_verified: hash['EmailAddress'].present?,
          email: hash['EmailAddress'],
          display_name: hash['DisplayName'],
          name: {
            givenName: hash['givenName'],
            familyName: hash['familyName'],
          },
          picture_url: '',
          uid: hash['Id'],
          language: hash['preferredLanguage'],
        }.with_indifferent_access
      end
    end
  end
end
