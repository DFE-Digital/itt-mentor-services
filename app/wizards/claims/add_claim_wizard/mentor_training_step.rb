class Claims::AddClaimWizard::MentorTrainingStep < BaseStep
  attribute :mentor_id
  attribute :hours_to_claim, :string
  attribute :custom_hours

  HOURS_TO_CLAIM = %w[maximum custom].freeze

  validates :mentor_id, presence: true
  validates :hours_to_claim, presence: true, inclusion: { in: HOURS_TO_CLAIM }

  validates(
    :custom_hours,
    presence: true,
    numericality: { only_integer: true },
    between: { min: 1, max: :max_hours },
    if: :custom_hours_selected?,
  )

  delegate :full_name, to: :mentor, prefix: true
  delegate :name, to: :provider, prefix: true
  delegate :provider, to: :wizard

  def initialize(wizard:, attributes:)
    super

    return if custom_hours_selected?

    self.custom_hours = nil
  end

  def mentor
    @mentor ||= @wizard.steps.fetch(:mentor).selected_mentors.find_by(id: mentor_id)
  end

  def max_hours
    training_allowance.remaining_hours
  end

  def training_allowance
    @training_allowance ||= Claims::TrainingAllowance.new(
      mentor:,
      provider:,
      academic_year: @wizard.academic_year,
    )
  end

  def hours_completed
    (hours_to_claim == "maximum" ? max_hours : custom_hours).to_i
  end

  private

  def custom_hours_selected?
    hours_to_claim == "custom"
  end
end
