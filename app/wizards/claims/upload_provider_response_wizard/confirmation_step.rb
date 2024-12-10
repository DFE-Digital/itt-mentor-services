class Claims::UploadProviderResponseWizard::ConfirmationStep < BaseStep
  delegate :claim_update_details, to: :wizard
end
