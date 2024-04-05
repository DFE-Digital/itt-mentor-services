class Claims::Support::Claim::MentorTrainingForm < Claims::Claim::MentorTrainingForm
  def back_path
    if mentor_trainings.index(mentor_training).zero?
      edit_claims_support_school_claim_mentor_path(claim.school, claim, mentor_training.mentor_id)
    else
      previous_mentor_training = mentor_trainings[mentor_trainings.index(mentor_training) - 1]
      edit_claims_support_school_claim_mentor_training_path(
        claim.school,
        claim,
        previous_mentor_training,
        params: {
          claims_support_claim_mentor_training_form: { hours_completed: previous_mentor_training.hours_completed },
        },
      )
    end
  end

  def success_path
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
