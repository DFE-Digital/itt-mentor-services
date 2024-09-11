class Placements::MentorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: Placements::MentorMembership.select(:mentor_id).where(school: user.current_organisation))
    end
  end
end
