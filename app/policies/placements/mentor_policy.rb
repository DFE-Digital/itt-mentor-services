class Placements::MentorPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.schools.joins(:mentor_memberships).select(:mentor_id))
    end
  end
end
