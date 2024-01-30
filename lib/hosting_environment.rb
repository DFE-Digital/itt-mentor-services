module HostingEnvironment
  PRODUCTION_BANNER_NAME = {
    claims: "beta",
    placements: "beta",
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
end
