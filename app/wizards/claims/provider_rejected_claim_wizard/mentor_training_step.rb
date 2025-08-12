class Claims::ProviderRejectedClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_training_ids, default: []

  delegate :mentor_trainings, :claim, to: :wizard

  validates :mentor_training_ids, presence: true

  def mentor_training_ids=(value)
    super normalised_mentor_training_ids(value)
  end

  private

  def normalised_mentor_training_ids(mentor_training_ids)
    if mentor_training_ids.blank?
      []
    else
      mentor_trainings.except(:order).where(id: mentor_training_ids).ids
    end
  end
end
