class Placements::UserMembershipPolicy < ApplicationPolicy
  def destroy?
    # Users cannot delete themselves
    return false if user == record.user

    user.support_user? ||
      user.user_memberships.exists?(
        organisation_id: record.organisation_id,
        organisation_type: record.organisation_type,
      )
  end

  def remove?
    destroy?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
