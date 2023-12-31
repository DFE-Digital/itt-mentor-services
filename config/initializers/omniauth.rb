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
  # TODO: Add DfE SignIn setup
end
