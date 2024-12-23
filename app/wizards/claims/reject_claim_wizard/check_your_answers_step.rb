class Claims::RejectClaimWizard::CheckYourAnswersStep < BaseStep
  delegate :not_assured_mentor_trainings, :claim, to: :wizard
end
