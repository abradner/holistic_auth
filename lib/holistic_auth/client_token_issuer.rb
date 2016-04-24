module HolisticAuth
  class ClientTokenIssuer
    # Options can
    def initialize(params, options = {})
      @params = params.with_indifferent_access
      provider_name = get_provider_name(options)
      unless HolisticAuth.configuration.providers.include? provider_name
        raise ArgumentError,
              "Provider #{provider_name} not in supported provider list:\n" <<
              HolisticAuth.configuration.providers.inspect
      end

      @provider = HolisticAuth.configuration.provider(provider_name)

      assign_instance_vars(options)
    end

    def authorize!(options = {})
      return { error: "Invalid Application #{@app_name}" }, :bad_request unless @valid_applications.include? @app_name

      validator = EndPointListener.new(auth_code: @auth_code, provider: @provider)
      raise "End provider/config not valid:\n #{validator.inspect}" unless validator.valid?

      handle(options)
    end

    def handle(options = {})
      provider_access_token = @provider.exchange @auth_code, @redirect_uri

      begin
        info = load_info(provider_access_token)
      rescue EmailNotVerifiedError => _e
        return { error: 'Cannot create a Foogi account with an unverified email address' }, :bad_request
      end

      orm_handler = HolisticAuth::OrmHandlers::ActiveRecord.new(info, @provider.name.to_s)

      user = orm_handler.discover_user!
      orm_handler.store_provider_credentials!(provider_access_token)

      token_data = prepare_token(provider_access_token, user, options.delete(:expires_in))

      [token_data.to_json, :ok]
    end

    def load_info(access_token)
      # raw_info = provider_access_token.get('https://www.googleapis.com/plus/v1/people/me/openIdConnect').parsed

      raw_info = @provider.retrieve_user_info(access_token)

      verified_email = raw_info[:email_verified] ? raw_info[:email] : nil
      raise EmailNotVerifiedError, 'Email not verified' unless verified_email.present?

      raw_info
    end

  private

    def prepare_token(provider_access_token, user, expires_in = 2.hours)
      application = Doorkeeper::Application.where(name: @app_name)

      client_access_token = Doorkeeper::AccessToken.create!(
        application_id: application,
        resource_owner_id: user.id,
        expires_in: expires_in,
        use_refresh_token: true,
        scopes: :user,
      )

      {
        access_token: client_access_token.token,
        refresh_token: client_access_token.refresh_token,
        token_type: 'bearer',
        expires_in: client_access_token.expires_in,
        user_id: user.to_param,
        provider_access_token: provider_access_token.token,
        provider_expires_in: provider_access_token.expires_in,
        # provider_id_token: provider_access_token.id_token,
      }
    end

    def application_name
      @params['application_name'].present? ? @params['application_name'].to_sym : nil
    end

    def prune!(hash)
      hash.delete_if do |_, v|
        prune!(v) if v.is_a?(Hash)
        v.nil? || (v.respond_to?(:empty?) && v.empty?)
      end
    end

    def get_provider_name(options)
      return options.delete(:provider) if options[:provider]
      return @params[:provider].to_sym if @params[:provider].present?
      nil
    end

    def assign_instance_vars(options)
      @auth_code = options.delete(:auth_code) || @params['code']
      @redirect_uri = options.delete(:redirect_uri) || @params['redirect_uri']
      @app_name = options.delete(:app_name) || application_name
      @valid_applications = options.delete(:valid_applications) || HolisticAuth.configuration.valid_applications
    end
  end
end
