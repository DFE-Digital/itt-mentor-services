class Claims::ChangeProviderWizard::CheckYourAnswersStep < BaseStep
  delegate :claim, :provider_name, :requires_audit?, :removed_mentor_trainings, :reduced_mentor_trainings, to: :wizard
end
