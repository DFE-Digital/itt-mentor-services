class Placements::SchoolContactPolicy < ApplicationPolicy
  def add_school_contact_journey?
    Placements::SchoolContact.find_by(
      school_id: record.school.id,
    ).blank?
  end
end
