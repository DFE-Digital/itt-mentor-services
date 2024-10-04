class Placements::UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      memberships = UserMembership.where(organisation: user.schools)
        .or(UserMembership.where(organisation: user.providers))
      scope.where(id: memberships.select(:user_id))
    end
  end
end
