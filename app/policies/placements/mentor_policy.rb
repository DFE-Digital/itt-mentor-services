class Placements::MentorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.joins(:mentor_memberships).where(mentor_memberships: { school: user.current_organisation })
    end
  end
end
