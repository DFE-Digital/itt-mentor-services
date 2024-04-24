class Claims::Claim::MentorsForm < ApplicationForm
  attr_accessor :claim, :mentor_ids

  validates :mentor_ids, presence: true

  def initialize(attributes = {})
    super

    self.mentor_ids ||= claim.mentor_ids
    self.mentor_ids.reject!(&:blank?)
  end

  def persist
    claim.mentor_trainings = mentor_trainings
    claim.save!
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

  def mentor_trainings
    @mentor_trainings ||= Array.wrap(mentor_ids).map do |mentor_id|
      claim.mentor_trainings.find_or_initialize_by(
        mentor_id:,
        provider_id: claim.provider_id,
        claim_id: claim.id,
      )
    end
  end
end
