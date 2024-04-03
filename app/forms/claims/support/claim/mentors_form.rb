class Claims::Support::Claim::MentorsForm < Claims::Claim::MentorsForm
  def update_success_path
    if claim.mentor_trainings.without_hours.any?
      edit_claims_support_school_claim_mentor_training_path(
        claim.school,
        claim,
        claim.mentor_trainings.without_hours.first,
      )
    else
      check_claims_support_school_claim_path(claim.school, claim)
    end
  end
end
