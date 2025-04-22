class Placements::HostingInterestPolicy < ApplicationPolicy
  def edit?
    next_academic_year = Placements::AcademicYear.current.next
    return false if record.academic_year != next_academic_year
    return true if record.appetite != "actively_looking"

    record
      .school
      .placements
      .where(academic_year: next_academic_year)
      .where.not(provider_id: nil)
      .blank?
  end
end
