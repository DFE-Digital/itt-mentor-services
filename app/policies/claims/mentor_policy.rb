class Claims::MentorPolicy < Claims::ApplicationPolicy
  def destroy?
    !Claims::Claim.active.joins(:mentor_trainings).where(mentor_trainings: { mentor_id: record }).exists?
  end

  def remove?
    true
  end
end
