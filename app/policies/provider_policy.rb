class ProviderPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: Placements::Partnership.select(:provider_id).where(school: user.schools))
    end
  end
end
