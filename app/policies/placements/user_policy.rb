class Placements::UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.support_user?
        scope
      else
        scope.where(id: UserMembership.select(:user_id).where(organisation: user.current_organisation))
      end
    end
  end
end
