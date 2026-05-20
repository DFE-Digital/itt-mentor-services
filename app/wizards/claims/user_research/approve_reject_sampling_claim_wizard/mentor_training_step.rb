class Claims::UserResearch::ApproveRejectSamplingClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_id
  attribute :hours_completed
  attribute :reason_not_assured

  validates :mentor_id, presence: true
  validate :hours_completed_within_available_range
  validates :reason_not_assured, presence: { message: "Please enter a reason" }, if: :reject_action?

  delegate :full_name, :trn, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :action, to: :wizard

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

  private

  def hours_completed_within_available_range
    return errors.add(:hours_completed, hours_range_message) if hours_completed.blank?

    entered_hours = Integer(hours_completed, exception: false)
    return errors.add(:hours_completed, hours_range_message) if entered_hours.nil?
    return if entered_hours.between?(1, max_hours)

    errors.add(:hours_completed, hours_range_message)
  end

  def hours_range_message
    "Enter a number of hours between 1 and #{max_hours}"
  end

  def reject_action?
    wizard.action == "reject"
  end
end
