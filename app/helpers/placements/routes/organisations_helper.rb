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

  def placements_support_organisation_path(organisation)
    case organisation
    when School
      placements_support_school_path(organisation)
    when Provider
      placements_support_provider_path(organisation)
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

  def placements_organisation_path(organisation)
    case organisation
    when School
      placements_school_placements_path(organisation)
    when Provider
      placements_provider_path(organisation)
    else
      raise NotImplementedError
    end
  end

  def placements_support_users_path(organisation)
    case organisation
    when School
      placements_support_school_users_path(organisation)
    when Provider
      placements_support_provider_users_path(organisation)
    else
      raise NotImplementedError
    end
  end

  def check_placements_organisation_users_path(organisation)
    case organisation
    when School
      check_placements_school_users_path(organisation)
    when Provider
      check_placements_provider_users_path(organisation)
    else
      raise NotImplementedError
    end
  end

  def placements_organisation_users_path(organisation)
    case organisation
    when School
      placements_school_users_path(organisation)
    when Provider
      placements_provider_users_path(organisation)
    else
      raise NotImplementedError
    end
  end

  def new_placements_organisation_user_path(organisation, params = {})
    case organisation
    when School
      new_placements_school_user_path(organisation, params)
    when Provider
      new_placements_provider_user_path(organisation, params)
    else
      raise NotImplementedError
    end
  end
end
