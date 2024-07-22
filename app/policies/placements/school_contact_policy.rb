class Placements::SchoolContactPolicy < ApplicationPolicy
  def add_school_contact_journey?
    !Placements::SchoolContact.where(
      school: record.school,
    ).exists?
  end
end
