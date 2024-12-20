class Claims::ProviderRejectedClaimWizard::CheckYourAnswersStep < BaseStep
  delegate :mentor_trainings, :claim, to: :wizard
end
