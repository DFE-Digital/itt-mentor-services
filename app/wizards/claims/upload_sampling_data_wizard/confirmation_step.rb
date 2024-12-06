class Claims::UploadSamplingDataWizard::ConfirmationStep < BaseStep
  delegate :uploaded_claim_ids, to: :wizard
end
