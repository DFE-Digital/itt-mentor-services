class Claims::UploadESFAClawbackResponseWizard::UploadErrorsStep < BaseStep
  delegate :invalid_claim_references,
           :invalid_status_claim_references,
           :missing_mentor_training_claim_references,
           :missing_reason_clawed_back_claim_references,
           :invalid_hours_clawed_back_claim_references,
           to: :upload_step

  def invalid_status_claims
    return [] if invalid_status_claim_references.blank?

    Claims::Claim.where(reference: invalid_status_claim_references)
  end

  def missing_mentor_claims
    return [] if missing_mentor_training_claim_references.blank?

    Claims::Claim.where(reference: missing_mentor_training_claim_references)
  end

  def missing_reason_clawed_back_claims
    return [] if missing_reason_clawed_back_claim_references.blank?

    Claims::Claim.where(reference: missing_reason_clawed_back_claim_references)
  end

  def invalid_hours_clawed_back_claims
    return [] if invalid_hours_clawed_back_claim_references.blank?

    Claims::Claim.where(reference: invalid_hours_clawed_back_claim_references)
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end
