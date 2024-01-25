module RoutesHelper
  def root_path
    {
      claims: claims_root_path,
      placements: placements_root_path,
    }.fetch current_service
  end

  def support_root_path
    {
      claims: claims_support_root_path,
      placements: placements_support_root_path,
    }.fetch current_service
  end

  def support_organisations_path
    {
      claims: claims_support_schools_path,
      placements: placements_support_organisations_path,
    }.fetch current_service
  end

  def user_path(user, organisation)
    if current_user.support_user?
      {
        claims: claims_support_school_user_path(id: user.id, school_id: organisation.id),
        placements: placements_support_school_user_path(id: user.id),
      }.fetch current_service
    else
      {
        claims: claims_school_user_path(id: user.id),
        placements: placements_school_user_path(id: user.id),
      }.fetch current_service
    end
  end

  def support_users_path
    {
      claims: claims_support_users_path,
      placements: placements_support_root_path,
    }.fetch current_service
  end

  def organisations_path
    {
      claims: claims_schools_path,
      placements: placements_organisations_path,
    }.fetch current_service
  end

  def placements_support_organisation_path(organisation)
    case organisation
    when School
      placements_support_school_path(organisation)
    when Provider
      placements_support_provider_path(organisation)
    end
  end

  def placements_support_users_path(organisation)
    case organisation
    when School
      placements_support_school_users_path(organisation)
    when Provider
      placements_support_provider_users_path(organisation)
    end
  end
end
