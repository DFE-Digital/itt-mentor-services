class SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: Placements::Partnership.select(:school_id).where(provider: user.providers))
    end
  end
end
