OmniAuth.config.logger = Rails.logger

# Implementation inspired by register-trainee-teachers repo
case ENV.fetch("SIGN_IN_METHOD", "persona")
when "persona"
  Rails
    .application
    .config
    .middleware
    .use(OmniAuth::Builder) do
      provider(
        :developer,
        fields: %i[uid email first_name last_name],
        uid_field: :uid,
      )
    end
when "dfe-sign-in"
  dfe_sign_in_issuer_uri = URI(ENV["DFE_SIGN_IN_ISSUER_URL"])

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect, {
      name: :dfe,
      discovery: true,
      scope: %i[email profile],
      response_type: :code,
      path_prefix: "/auth",
      callback_path: "/auth/dfe/callback",
      issuer: "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}",
      setup: SETUP_PROC,
    }
  end

  SETUP_PROC = lambda do |env|
    request = Rack::Request.new(env)
    service = HostingEnvironment.current_service(request)

    dfe_sign_in_redirect_uri = URI.join(request.base_url, "/auth/dfe/callback")

    env["omniauth.strategy"].options.client_options = {
      port: dfe_sign_in_issuer_uri&.port,
      scheme: dfe_sign_in_issuer_uri&.scheme,
      host: dfe_sign_in_issuer_uri&.host,
      identifier: HostingEnvironment.dfe_sign_in_client_id(service),
      secret: HostingEnvironment.dfe_sign_in_secret(service),
      redirect_uri: dfe_sign_in_redirect_uri,
    }
  end
end
