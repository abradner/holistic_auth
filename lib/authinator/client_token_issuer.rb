module Authinator
  class ClientTokenIssuer
    TEMP_RAW_INFO = {
      email_verified: true,
      email: 'a@b.c',
      given_name: 'first',
      family_name: 'last',
      profile: 'xyz',
    }.with_indifferent_access

    # Options can
    def initialize(params, options = {})
      @params = params.with_indifferent_access
      provider_name = (options.delete :provider if options[:provider]) || (@params[:provider].present? ? @params[:provider].to_sym : nil)
      unless Authinator.configuration.providers.include? provider_name
        fail ArgumentError,
             "Provider #{provider_name} not in supported parameter list:\n" <<
               Authinator.configuration.providers.inspect
      end

      @provider = Authinator.configuration.provider_for(provider_name)

      @auth_code = (options.delete :auth_code if options[:auth_code]) || @params['code']
      @app_name = (options.delete :app_name if options[:app_name]) || application_name
      @valid_applications = (options.delete :valid_applications if options[:valid_applications]) || Authinator.configuration.valid_applications
    end

    def authorize!(options = {})
      return { error: "Invalid Application #{@app_name}" }, :bad_request unless @valid_applications.include? @app_name

      handler = EndPointListener.new(auth_code: @auth_code, provider: @provider)

      if handler.valid?
        return handle(options)

      else
        # Doorkeeper's defaut behaviour when the user signs in with login/password.
        # TODO: kill this block
        begin
          response = strategy.authorize
          headers.merge! response.headers
          self.response_body = response.body.merge(user_id: (response.token.resource_owner_id && response.token.resource_owner_id.to_s)).to_json
          self.status = response.status
        rescue Doorkeeper::Errors::DoorkeeperError => e
          handle_token_exception e
        end

      end
    end

    def handle(options = {})
      application = Doorkeeper::Application.where(name: @app_name)
      token_issuer = AuthCodeExchanger.new @provider
      provider_access_token = token_issuer.exchange @auth_code

      begin
        info = load_info(provider_access_token)
      rescue ArgumentError => _e
        return { error: 'Cannot create a Foogi account with an unverified email address' }, :bad_request
      end

      user = find_user(info)
      expires_in = options.delete(:expires_in) || 2.hours

      client_access_token = Doorkeeper::AccessToken.create!(
        application_id: application,
        resource_owner_id: user.id,
        expires_in: expires_in,
        use_refresh_token: true,
      )

      token_data = {
        access_token: client_access_token.token,
        refresh_token: client_access_token.refresh_token,
        token_type: 'bearer',
        expires_in: client_access_token.expires_in,
        user_id: user.id, # TODO: remove
        provider_access_token: provider_access_token.token,
        provider_expires_in: provider_access_token.expires_in,
      }

      [token_data.to_json, :ok]
    end

    def find_user(info)
      User.find_by(primary_email: info[:email]) || User.create!(
        primary_email: info[:email], display_name: info[:name], # uid: uid,
      )
    end

    def load_info(access_token)
      # raw_info = provider_access_token.get('https://www.googleapis.com/plus/v1/people/me/openIdConnect').parsed

      raw_info = case @provider.name
                   when :google
                     retrieve_user_from_google access_token
                   when :stub
                     TEMP_RAW_INFO
                 end

      verified_email = raw_info['email_verified'] ? raw_info['email'] : nil
      fail ArgumentError, 'Email not verified' unless verified_email.present?

      prune!(
        name: raw_info['name'],
        email: verified_email,
        first_name: raw_info['given_name'],
        last_name: raw_info['family_name'],
        image: raw_info['image_url'],
        uid: raw_info['sub'] || verified_email,
        urls: {
          @provider.name => raw_info['profile'],
        },
      )
    end

  private

    def application_name
      @params['application_name'].present? ? @params['application_name'].to_sym : nil
    end

    def prune!(hash)
      hash.delete_if do |_, v|
        prune!(v) if v.is_a?(Hash)
        v.nil? || (v.respond_to?(:empty?) && v.empty?)
      end
    end

    def retrieve_user_from_google(token)
      client = GoogleClientBuilder.new('plus', 'v1', 1)
      _status, _headers, body = client.execute token, plus.people.get, userId: 'me'
      JSON.parse(body[0])
    end
  end
end
