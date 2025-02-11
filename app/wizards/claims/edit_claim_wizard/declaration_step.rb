class Claims::EditClaimWizard::DeclarationStep < BaseStep
  delegate :claim, to: :wizard
  delegate :total_hours_completed, :mentors, :mentor_trainings, :amount, to: :claim
end
