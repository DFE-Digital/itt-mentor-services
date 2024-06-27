class Placements::UserMembershipPolicy < ApplicationPolicy
  def destroy?
    return false unless user != record.user

    user.support_user? ||
      user.schools.ids.include?(record.organisation.id) ||
      user.providers.ids.include?(record.organisation.id)
  end

  def remove?
    destroy?
  end
end
