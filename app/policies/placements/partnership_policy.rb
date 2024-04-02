class Placements::PartnershipPolicy < ApplicationPolicy
  def destroy?
    user.schools.include?(record.school) ||
      user.providers.include?(record.provider)
  end

  def remove?
    destroy?
  end
end
