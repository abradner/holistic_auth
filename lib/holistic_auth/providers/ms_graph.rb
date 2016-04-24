module HolisticAuth
  module Providers
    class MsGraph < GenericProvider
      GRAPH_RESOURCE = 'https://graph.microsoft.com'.freeze
      DEFAULT_CONTENT_TYPE = 'application/json;odata.metadata=minimal;odata.streaming=true'.freeze
      API_VERSION = 'beta'.freeze

      SETTINGS = {
        site: 'https://login.microsoftonline.com',
        token_url: 'oauth2/token',
        user_info_url: URI("#{GRAPH_RESOURCE}/#{API_VERSION}/me"),
        additional_parameters: {
          resource: GRAPH_RESOURCE,
        },
      }.freeze

      def settings
        SETTINGS
      end

      def name
        :ms_graph
      end

      def full_site_url
        tenant_id.present? ? (site + '/' + tenant_id + '/') : (site + '/common/')
      end

      def retrieve_user_info(access_token)
        result = query! :get, access_token.token, SETTINGS[:user_info_url]
        process_info JSON.parse(result.body)
      end

      def process_info(hash)
        raise "Can't process empty user info" unless hash.is_a? Hash

        if hash.key?('error')
          raise "Could not process user info: \n #{hash['error']['code']}: #{hash['error']['message']}"
        end

        {
          email_verified: hash['mail'].present?,
          email: hash['mail'],
          display_name: hash['displayName'],
          name: {
            givenName: hash['givenName'],
            familyName: hash['familyName'],
          },
          picture_url: '',
          uid: hash['id'],
          language: hash['preferredLanguage'],
        }.with_indifferent_access
      end

      # def events
      #   query_params = {
      #     startdatetime: DateTime.now.utc,
      #     enddatetime: DateTime.now.utc + 2.months,
      #     '$orderby' => 'start/dateTime',
      #   }
      # end

      # Need error handling for when the token has expired.
      def query!(method, access_token, uri, body = nil)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        headers = {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => DEFAULT_CONTENT_TYPE,
        }

        full_endpoint = uri.query.present? ? "#{uri.path}?#{uri.query}" : uri.path

        response =
          case method
            when :get
              http.get(full_endpoint, headers)
            when :post
              http.post(full_endpoint, body, headers)
            else
              raise "method #{method} not implemented"
          end

        response
      end
    end
  end
end
