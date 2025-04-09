class Placements::Partnership::ProviderPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.schools.joins(:partnerships).select(:provider_id))
    end
  end

  def index?
    Flipper.enabled?(:school_partner_providers, record)
  end
end
