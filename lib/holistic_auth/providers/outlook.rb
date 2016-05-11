module HolisticAuth
  module Providers
    class Outlook < MsGraph
      GRAPH_RESOURCE = 'https://outlook.office.com/api/'.freeze
      API_VERSION = 'v2.0'.freeze

      SETTINGS = {
        site: 'https://login.microsoftonline.com',
        token_url: 'oauth2/token',
        user_info_url: URI("#{GRAPH_RESOURCE}/#{API_VERSION}/me"),
        additional_parameters: {
          resource: GRAPH_RESOURCE,
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
