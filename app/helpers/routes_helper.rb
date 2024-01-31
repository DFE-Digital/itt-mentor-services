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

  def feedback_path
    {
      claims: claims_feedback_path,
      placements: placements_feedback_path,
    }.fetch current_service
  end

  def organisation_users_path(organisation)
    case organisation
    when School
      placements_school_users_path(organisation)
    when Provider
      placements_provider_users_path(organisation)
    end
  end

  def placements_support_organisation_path(organisation)
    case organisation
    when School
      placements_support_school_path(organisation)
    when Provider
      placements_support_provider_path(organisation)
    end
  end

  def placements_organisation_user_path(organisation, user)
    case organisation
    when School
      placements_school_user_path(organisation, user)
    when Provider
      placements_provider_user_path(organisation, user)
    end
  end

  def placements_organisation_path(organisation)
    case organisation
    when School
      placements_school_path(organisation)
    when Provider
      placements_provider_path(organisation)
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

  def check_placements_organisation_users_path(organisation)
    case organisation
    when School
      check_placements_school_users_path
    when Provider
      check_placements_provider_users_path
    end
  end

  def placements_organisation_users_path(organisation)
    case organisation
    when School
      placements_school_users_path(organisation)
    when Provider
      placements_provider_users_path(organisation)
    end
  end

  def new_placements_organisation_user_path(organisation, params = {})
    case organisation
    when School
      new_placements_school_user_path(organisation, params)
    when Provider
      new_placements_provider_user_path(organisation, params)
    end
  end

  def omniauth_sign_in_path(provider)
    "/auth/#{provider}"
  end
end
