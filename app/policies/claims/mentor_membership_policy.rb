class Claims::MentorMembershipPolicy < Claims::ApplicationPolicy
  def destroy?
    !Claims::Claim.active.joins(:mentor_trainings).where(mentor_trainings: { mentor_id: record.mentor_id }).where(claims: { school_id: record.school_id }).exists?
  end

  def remove?
    true
  end
end
