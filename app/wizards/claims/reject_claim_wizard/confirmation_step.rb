class Claims::RejectClaimWizard::ConfirmationStep < BaseStep
  delegate :claim, to: :wizard
end
