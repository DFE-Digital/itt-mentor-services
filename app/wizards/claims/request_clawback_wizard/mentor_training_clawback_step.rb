class Claims::RequestClawbackWizard::MentorTrainingClawbackStep < BaseStep
  attribute :mentor_training_id
  attribute :number_of_hours
  attribute :reason_for_clawback

  validates :mentor_training_id, presence: true
  validates :number_of_hours, presence: true, numericality: { only_integer: true, less_than: proc { |step| step.mentor_training.hours_completed }, greater_than_or_equal_to: 0 }
  validates :reason_for_clawback, presence: true

  delegate :mentor_trainings, :claim, to: :wizard
  delegate :hours_completed, to: :claim
  delegate :mentor, :reason_rejected, :reason_not_assured, to: :mentor_training
  delegate :full_name, :full_name_possessive, to: :mentor, prefix: true

  def mentor_training
    mentor_trainings.find(mentor_training_id)
  end

  def hours_clawed_back
    mentor_training.hours_completed - number_of_hours.to_i
  end
end
