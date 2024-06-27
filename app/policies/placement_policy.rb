class PlacementPolicy < ApplicationPolicy
  def new?
    record.school.school_contact.present?
  end

  def update?
    record.school.school_contact.present?
  end
  alias_method :edit_provider?, :update?
  alias_method :edit_mentors?, :update?
end
