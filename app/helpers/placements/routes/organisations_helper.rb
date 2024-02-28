module Placements::Routes::OrganisationsHelper
  def organisation_users_path(organisation)
    polymorphic_path([:placements, Placements::ConvertInstanceToBaseInstance.call(organisation), :users])
  end

  def placements_support_organisation_path(organisation)
    polymorphic_path([:placements, :support, Placements::ConvertInstanceToBaseInstance.call(organisation)])
  end

  def placements_organisation_user_path(organisation, user)
    polymorphic_path([:placements,
                      Placements::ConvertInstanceToBaseInstance.call(organisation),
                      Placements::ConvertInstanceToBaseInstance.call(user)])
  end

  def placements_organisation_path(organisation)
    case organisation
    when School
      polymorphic_path([:placements, Placements::ConvertInstanceToBaseInstance.call(organisation), :placements])
    when Provider
      polymorphic_path([:placements, Placements::ConvertInstanceToBaseInstance.call(organisation)])
    else
      raise NotImplementedError
    end
  end

  def placements_support_users_path(organisation)
    polymorphic_path([:placements, :support, Placements::ConvertInstanceToBaseInstance.call(organisation), :users])
  end

  def check_placements_organisation_users_path(organisation)
    polymorphic_path([:check, :placements, Placements::ConvertInstanceToBaseInstance.call(organisation), :users])
  end

  def placements_organisation_users_path(organisation)
    polymorphic_path([:placements, Placements::ConvertInstanceToBaseInstance.call(organisation), :users])
  end

  def new_placements_organisation_user_path(organisation, params = {})
    new_polymorphic_path([:placements, Placements::ConvertInstanceToBaseInstance.call(organisation), :user], params)
  end
end
