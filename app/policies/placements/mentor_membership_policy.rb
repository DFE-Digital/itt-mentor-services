class Placements::MentorMembershipPolicy < ApplicationPolicy
  def destroy?
    mentor = record.mentor
    school = record.school
    mentor.placements.where(school:).empty?
  end
end
