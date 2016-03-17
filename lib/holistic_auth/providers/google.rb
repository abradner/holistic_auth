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

      def name
        :google
      end

      def retrieve_user_info(access_token)
        client = GoogleClient::Builder.new('plus', 'v1', 1)
        result = client.execute access_token,
                                api_method: client.service.people.get,
                                parameters: {
                                  userId: 'me',
                                }

        process_google_info JSON.parse(result.body)
      end

    private

      def process_google_info(hash)
        {
          email_verified: hash['emails'].first['type'].eql?('account'),
          email: hash['emails'].first['value'],
          display_name: hash['displayName'],
          name: hash['name'],
          picture_url: hash['image']['url'],
          uid: hash['id'],
          language: hash['language'],
        }.with_indifferent_access

        # {
        #   "kind" => "plus#person",
        #   "etag" => "\"xyz-something/abc\"",
        #   "gender" => "female",
        #   "emails" => [
        #     {
        #       "value" => "info@foogi.me",
        #       "type" => "account"
        #     }
        #   ],
        #   "objectType" => "person",
        #   "id" => "12345",
        #   "displayName" => "Leading Foogster",
        #   "name" => {
        #     "familyName" => "Foogster",
        #     "givenName" => "Leading"
        #   },
        #   "url" => "https://plus.google.com/+FoogiMe",
        #   "image" => {
        #     "url" => "https://someurl/photo.jpg?sz=50",
        #     "isDefault" => false
        #   },
        #   "placesLived" => [
        #     {
        #       "value" => "Sydney, Australia",
        #       "primary" => true
        #     },
        #     {
        #       "value" => "San Francisco, USA"
        #     }
        #   ],
        #   "isPlusUser" => true,
        #   "language" => "en_GB",
        #   "circledByCount" => 11225,
        #   "verified" => false,
        #   "domain" => "foogi.me"
        # }
      end
    end
  end
end
