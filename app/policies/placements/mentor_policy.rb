class Placements::MentorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(
        mentor_memberships: { school: user.current_organisation },
      ).or(
        scope.where(
          id: Placements::MentorMembership.select(:mentor_id).where(school: user.current_organisation),
        ),
      )
    end
  end
end
