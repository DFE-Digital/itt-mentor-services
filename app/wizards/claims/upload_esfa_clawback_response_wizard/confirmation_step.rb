class Claims::UploadESFAClawbackResponseWizard::ConfirmationStep < BaseStep
  delegate :claims_count, to: :wizard
end
