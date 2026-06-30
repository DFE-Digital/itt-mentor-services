class Claims::UserResearch::ApproveRejectSamplingClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_id
  attribute :hours_option, :string
  attribute :custom_hours
  attribute :reason_not_assured

  REMOVE_ALL_HOURS = "remove_all".freeze
  CUSTOM_HOURS = "custom".freeze
  HOURS_OPTIONS = [REMOVE_ALL_HOURS, CUSTOM_HOURS].freeze

  validates :mentor_id, presence: true
  validates :hours_option, presence: true, inclusion: { in: HOURS_OPTIONS }, if: :reject_action?
  validate :custom_hours_within_available_range, if: :custom_hours_selected?
  validates :reason_not_assured, presence: { message: "Please enter a reason" }, if: :reject_action?

  delegate :full_name, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :action, to: :wizard

  def initialize(wizard:, attributes:)
    super

    return if custom_hours_selected?

    self.custom_hours = nil
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

  def completed_hours
    return 0 if hours_option == REMOVE_ALL_HOURS

    custom_hours.to_i
  end

  alias_method :trained_hours, :completed_hours
  alias_method :worked_hours, :completed_hours

  private

  def custom_hours_selected?
    hours_option == CUSTOM_HOURS
  end

  def custom_hours_within_available_range
    return errors.add(:custom_hours, hours_range_message) if custom_hours.blank?

    entered_hours = Integer(custom_hours, exception: false)
    return errors.add(:custom_hours, hours_range_message) if entered_hours.nil?
    return if entered_hours.between?(1, max_hours)

    errors.add(:custom_hours, hours_range_message)
  end

  def hours_range_message
    "Enter a number of hours between 1 and #{max_hours}"
  end

  def reject_action?
    wizard.action == "reject"
  end
end
