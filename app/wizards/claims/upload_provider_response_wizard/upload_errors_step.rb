class Claims::UploadProviderResponseWizard::UploadErrorsStep < BaseStep
  delegate :invalid_status_claim_references,
           :missing_mentor_training_claim_references,
           :invalid_assured_status_claim_references,
           :missing_assured_reason_claim_references,
           to: :upload_step

  def invalid_status_claims
    return [] if invalid_status_claim_references.blank?

    Claims::Claim.where(reference: invalid_status_claim_references)
  end

  def missing_mentor_claims
    return [] if missing_mentor_training_claim_references.blank?

    Claims::Claim.where(reference: missing_mentor_training_claim_references)
  end

  def invalid_assured_status_claims
    return [] if invalid_assured_status_claim_references.blank?

    Claims::Claim.where(reference: invalid_assured_status_claim_references)
  end

  def missing_assured_reason_claims
    return [] if missing_assured_reason_claim_references.blank?

    Claims::Claim.where(reference: missing_assured_reason_claim_references)
  end

  private

  def upload_step
    @upload_step ||= wizard.steps.fetch(:upload)
  end
end
