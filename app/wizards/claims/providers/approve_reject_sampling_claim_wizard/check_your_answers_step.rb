class Claims::Providers::ApproveRejectSamplingClaimWizard::CheckYourAnswersStep < BaseStep
  delegate :claim, :mentor_trainings, :action, to: :wizard
end
