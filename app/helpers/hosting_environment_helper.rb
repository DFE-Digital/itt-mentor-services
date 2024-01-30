module HostingEnvironmentHelper
  HOSTING_ENVIRONMENT_COLORS = {
    production: "blue",
    qa: "orange",
    staging: "red",
    sandbox: "purple",
    review: "purple",
  }.with_indifferent_access.freeze

  def hosting_environment_color
    HOSTING_ENVIRONMENT_COLORS.fetch(HostingEnvironment.env, "grey")
  end

  def hosting_environment_phase(current_service)
    return "QA" if HostingEnvironment.phase(current_service) == "qa"

    HostingEnvironment.phase(current_service).titleize
  end
end
