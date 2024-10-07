module Placements::Routes::OrganisationsHelper
  def organisation_users_path(organisation)
    case organisation
    when School
      placements_school_users_path(organisation)
    when Provider
      placements_provider_users_path(organisation)
    else
      raise NotImplementedError
    end
  end

  def placements_organisation_user_path(organisation, user)
    case organisation
    when School
      placements_school_user_path(organisation, user)
    when Provider
      placements_provider_user_path(organisation, user)
    else
      raise NotImplementedError
    end
  end
end
