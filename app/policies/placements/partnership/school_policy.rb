class Placements::Partnership::SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.providers.joins(:partnerships).select(:school_id))
    end
  end
end
