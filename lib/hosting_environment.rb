module HostingEnvironment
  PRODUCTION_BANNER_NAME = {
    claims: "beta",
    placements: "beta",
  }.with_indifferent_access.freeze

  DFE_SIGN_IN_CLIENT_IDS = {
    claims: ENV["CLAIMS_DFE_SIGN_IN_CLIENT_ID"],
    placements: ENV["PLACEMENTS_DFE_SIGN_IN_CLIENT_ID"],
  }.with_indifferent_access.freeze

  DFE_SIGN_IN_CLIENT_SECRETS = {
    claims: ENV["CLAIMS_DFE_SIGN_IN_SECRET"],
    placements: ENV["PLACEMENTS_DFE_SIGN_IN_SECRET"],
  }.with_indifferent_access.freeze

  def self.env
    @env ||= ActiveSupport::EnvironmentInquirer.new(ENV["HOSTING_ENV"].presence || "development")
  end

  def self.phase(current_service)
    @phase ||= if env.production?
                 PRODUCTION_BANNER_NAME.fetch(current_service)
               else
                 env
               end
  end

  def self.dfe_sign_in_client_id(current_service)
    DFE_SIGN_IN_CLIENT_IDS.fetch(current_service)
  end

  def self.dfe_sign_in_secret(current_service)
    DFE_SIGN_IN_CLIENT_SECRETS.fetch(current_service)
  end

  def self.current_service(request)
    case request.host
    when ENV["CLAIMS_HOST"], *ENV.fetch("CLAIMS_HOSTS", "").split(",")
      :claims
    when ENV["PLACEMENTS_HOST"], *ENV.fetch("PLACEMENTS_HOSTS", "").split(",")
      :placements
    end
  end
end
