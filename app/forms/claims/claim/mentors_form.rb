class Claims::Claim::MentorsForm < ApplicationForm
  attr_accessor :claim, :mentor_ids

  validate :mentor_presence

  def persist
    updated_claim.save!
  end

  def to_model
    claim
  end

  def update_success_path
    if claim.mentor_trainings.without_hours.any?
      edit_claims_school_claim_mentor_training_path(
        claim.school,
        claim,
        claim.mentor_trainings.without_hours.first,
      )
    else
      check_claims_school_claim_path(claim.school, claim)
    end
  end

  private

  def updated_claim
    @updated_claim ||= begin
      claim.mentor_trainings = mentor_trainings
      claim
    end
  end

  def mentor_trainings
    @mentor_trainings ||= Array.wrap(mentor_ids).map do |mentor_id|
      claim.mentor_trainings.find_or_initialize_by(
        mentor_id:,
        provider_id: claim.provider_id,
        claim_id: claim.id,
      )
    end
  end

  def mentor_presence
    if updated_claim.mentor_trainings.blank?
      updated_claim.errors.add(:mentor_ids, :blank)
      add_errors_to_form
    end
  end

  def add_errors_to_form
    updated_claim.errors.each do |err|
      errors.add(err.attribute, err.message)
    end
  end
end
