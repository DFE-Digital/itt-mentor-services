class Placements::UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.support_user?
        scope
      else
        scope.joins(:user_memberships).where(user_memberships: { organisation: user.current_organisation })
      end
    end
  end
end
