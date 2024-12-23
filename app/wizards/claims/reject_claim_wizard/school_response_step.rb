class Claims::RejectClaimWizard::SchoolResponseStep < BaseStep
  attribute :mentor_training_id
  attribute :reason_rejected

  delegate :not_assured_mentor_trainings, :claim, to: :wizard
  delegate :mentor, :hours_completed, :reason_not_assured, to: :mentor_training

  validates :reason_rejected, presence: true
  validates :mentor_training_id, presence: true

  private

  def mentor_training
    not_assured_mentor_trainings.find(mentor_training_id)
  end
end
