class Claims::ApproveSamplingClaimWizard::CheckYourAnswersStep < BaseStep
  delegate :mentor_training_steps, :claim, :mentor_trainings, to: :wizard
end
