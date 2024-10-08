class Placements::SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.schools)
    end
  end
end
