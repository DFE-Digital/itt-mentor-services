class Claims::ApproveSamplingClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_id
  attribute :hours_completed

  validates :mentor_id, presence: true
  validates :hours_completed, presence: true, numericality: { only_integer: true, greater_than: 0 }

  delegate :full_name, :trn, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :wizard, to: :wizard

  def initialize(wizard:, attributes:)
    super
  end

  def mentor
    @mentor ||= wizard.mentor_trainings.find { |mt| mt.mentor_id.to_s == mentor_id.to_s }&.mentor
  end

  def mentor_training
    @mentor_training ||= wizard.mentor_trainings.find { |mt| mt.mentor_id.to_s == mentor_id.to_s }
  end

  def provider
    mentor_training&.provider
  end

  def max_hours
    mentor_training&.hours_completed || 0
  end

  def training_type
    mentor_training&.training_type || :initial
  end
end
