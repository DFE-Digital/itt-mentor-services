class Claims::ProviderRejectedClaimWizard::ProviderResponseStep < BaseStep
  attribute :mentor_training_id
  attribute :reason_not_assured

  delegate :mentor_trainings, :claim, to: :wizard
  delegate :mentor, :hours_completed, to: :mentor_training

  validates :reason_not_assured, presence: true
  validates :mentor_training_id, presence: true

  private

  def mentor_training
    mentor_trainings.find(mentor_training_id)
  end
end
