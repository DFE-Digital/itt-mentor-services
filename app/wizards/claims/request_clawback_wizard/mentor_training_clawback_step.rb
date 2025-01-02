class Claims::RequestClawbackWizard::MentorTrainingClawbackStep < BaseStep
  attribute :mentor_training_id
  attribute :number_of_hours, :integer
  attribute :reason_for_clawback

  validates :mentor_training_id, presence: true
  validates :number_of_hours, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 20 }
  validates :reason_for_clawback, presence: true

  delegate :mentor_trainings, to: :wizard
  delegate :mentor, :reason_rejected, :reason_not_assured, to: :mentor_training
  delegate :full_name, to: :mentor, prefix: true

  def mentor_training
    mentor_trainings.find(mentor_training_id)
  end
end
