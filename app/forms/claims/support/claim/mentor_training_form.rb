class Claims::Support::Claim::MentorTrainingForm < Claims::Claim::MentorTrainingForm
  def back_path
    if mentor_trainings.index(mentor_training).zero?
      edit_claims_support_school_claim_mentors_path(school, claim)
    else
      edit_claims_support_school_claim_mentor_training_path(school, claim, previous_mentor_training)
    end
  end

  def success_path
    if claim.mentor_trainings.without_hours.any?
      edit_claims_support_school_claim_mentor_training_path(school, claim, claim.mentor_trainings.without_hours.first)
    else
      check_claims_support_school_claim_path(school, claim)
    end
  end
end
