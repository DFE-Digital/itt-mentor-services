class Claims::AddClaimWizard::CheckYourAnswersStep < BaseStep
  validate :mentors_have_claimable_hours

  delegate :claim, to: :wizard

  def mentors_have_claimable_hours
    return unless claim.mentor_trainings.empty? || !claim.valid_mentor_training_hours?

    errors.add(:base, :unclaimable)
  end
end
