module HostingEnvironment
  PRODUCTION_BANNER_NAME = {
    claims: "beta",
    placements: "beta",
  }.with_indifferent_access.freeze

  def self.name(current_service)
    if Rails.env.production?
      PRODUCTION_BANNER_NAME.fetch(current_service)
    else
      Rails.env
    end
  end

  def self.banner_description(current_service)
    I18n.t(".models.hosting_environment.#{current_service}.banner.description")
  end
end
