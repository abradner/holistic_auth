module HolisticAuth
  module OrmHandlers
    class ActiveRecord
      # TODO: Railtie this properly rather than hacks
      require 'active_record'

      attr_reader :info, :account, :provider_name

      def initialize(info, provider_name)
        @info = info
        @provider_name = provider_name
      end

      def discover_user!
        discover_account!.user
      end

      def discover_account!
        @account.present? ? @account : (@account = find_or_create_account)
      end

      def store_provider_credentials!(access_token)
        fail 'Account not discovered yet!' unless @account.present?

        @account.replace_credential!(
          access_token: access_token.token,
          refresh_token: access_token.refresh_token,
          expires_at: (Time.now.utc + access_token.expires_in),
          expires: access_token.expires_in.present? ? true : false,
        )
      end

    private

      def find_or_create_account
        Account.find_by(email: info[:email], provider: @provider_name) || create_account!
      end

      def create_account!
        user = User.find_by(primary_email: info[:email]) || create_user!
        user.create_account!(
          email: info[:email],
          provider: @provider_name,
          provider_uid: info[:uid],
        )
      end

      def create_user!
        User.create!(
          primary_email: info[:email], display_name: info[:display_name],
          name: info[:name], picture_url: info[:picture_url],
        )
      end
    end
  end
end
