class Claims::MentorMembershipPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def destroy?
    !Claims::Claim.active.joins(:mentor_trainings).where(school_id: record.school_id, mentor_trainings: { mentor_id: record.mentor_id }).exists?
  end

  def remove?
    true
  end
end
