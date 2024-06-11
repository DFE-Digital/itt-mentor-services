module RoutesHelper
  include Placements::Routes::OrganisationsHelper

  CLAIMS_FEEDBACK_URL = "https://forms.office.com/e/0E3277Kqpi".freeze
  PLACEMENTS_FEEDBACK_URL = "https://forms.office.com/e/2dZ8gck5Zg".freeze

  def root_path
    {
      claims: sign_in_path,
      placements: placements_root_path,
    }.fetch HostingEnvironment.current_service(request)
  end

  def support_root_path
    {
      claims: claims_support_root_path,
      placements: placements_support_root_path,
    }.fetch HostingEnvironment.current_service(request)
  end

  def support_organisations_path
    {
      claims: claims_support_schools_path,
      placements: placements_support_organisations_path,
    }.fetch HostingEnvironment.current_service(request)
  end

  def support_support_users_path
    {
      claims: claims_support_support_users_path,
      placements: placements_support_support_users_path,
    }.fetch HostingEnvironment.current_service(request)
  end

  def organisations_path
    {
      claims: claims_schools_path,
      placements: placements_organisations_path,
    }.fetch HostingEnvironment.current_service(request)
  end

  def feedback_url
    {
      claims: CLAIMS_FEEDBACK_URL,
      placements: PLACEMENTS_FEEDBACK_URL,
    }.fetch HostingEnvironment.current_service(request)
  end

  def omniauth_sign_in_path(provider)
    "/auth/#{provider}"
  end
end
